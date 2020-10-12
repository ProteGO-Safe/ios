//
//  DistrictService.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 11/10/2020.
//

import Foundation
import Moya
import PromiseKit
import Realm

final class DistrictService {
    
    struct Response {
        let allDistrictsJSON: String?
        let observedJSON: String?
        let changedObserved: [DistrictStorageModel]
    }
    
    private struct InternalResponse {
        let all: [VoivodeshipStorageModel]
        let allChanged: [DistrictStorageModel]
        let observed: [ObservedDistrictStorageModel]
    }
    
    private let provider: MoyaProvider<DistrictsTarget>
    private let localStorage: RealmLocalStorage?
    
    init(
        with provider: MoyaProvider<DistrictsTarget>,
        localStorage: RealmLocalStorage? = RealmLocalStorage()
    ) {
        self.provider = provider
        self.localStorage = localStorage
    }
    
    func perform(shouldFetchAPIData: Bool = true) -> Promise<DistrictService.Response> {
        return internalProcess(shouldFetchAPIData: shouldFetchAPIData)
            .then { internalResponse in
                return self.allDistrictsJSON(internalresponse: internalResponse).map { ($0, internalResponse) }
        }
        .then { allDistrictsJSON, internalResponse in
            self.observedJSON(internalresponse: internalResponse).map { (allDistrictsJSON, $0, internalResponse) }
        }
        .then { allDistrictsJSON, observedJSON, internalResponse in
            self.changedObserved(internalResponse: internalResponse).map { (allDistrictsJSON, observedJSON, $0) }
        }
        .then { allDistrictsJSON, observedJSON, changedObserved -> Promise<Response> in
            return .value(Response(allDistrictsJSON: allDistrictsJSON, observedJSON: observedJSON, changedObserved: changedObserved))
        }
        .recover { _ -> Promise<Response> in
            return self.allDistrictsJSONFailure()
        }
        
    }
    
    func manageObserved(model: DistrictObservedManageModel) {
        switch model.type {
        case .add:
            addObserved(districtId: model.districtId)
        case .delete:
            removeObserved(districtId: model.districtId)
        }
    }
    
    func addObserved(districtId: Int) {
        guard let model: DistrictStorageModel = localStorage?.fetch(primaryKey: districtId) else { return }
        
        let observed = ObservedDistrictStorageModel()
        observed.districtId = districtId
        observed.name = model.name
        
        localStorage?.append(observed)
    }
    
    func removeObserved(districtId: Int) {
        guard
            let observed: ObservedDistrictStorageModel = localStorage?.fetch(primaryKey: districtId)
            else { return }
        
        localStorage?.remove(observed)
    }
    
    private func fetchObserved() -> Promise<[ObservedDistrictStorageModel]> {
        return Promise { seal in
            seal.fulfill((localStorage?.fetch() ?? []).sorted(by: { $0.createdAt < $1.createdAt }))
        }
    }
    
    private func internalProcess(shouldFetchAPIData: Bool = true) -> Promise<InternalResponse> {
        if shouldFetchAPIData {
            return fetch()
                .then(store)
                .then(getAll)
                .then { all in
                    return self.fetchChanged().map { (all, $0) }
            }
            .then { all, changed in
                return self.fetchObserved().map { InternalResponse(all: all, allChanged: changed, observed: $0) }
            }
        } else {
            return getAll()
                .then { all in
                    return self.fetchChanged().map { (all, $0) }
            }
            .then { all, changed in
                return self.fetchObserved().map { InternalResponse(all: all, allChanged: changed, observed: $0) }
            }
        }
    }
    
    private func changedObserved(internalResponse: InternalResponse) -> Promise<[DistrictStorageModel]> {
        return Promise { seal in
            guard !internalResponse.observed.isEmpty, !internalResponse.allChanged.isEmpty else {
                return seal.fulfill([])
            }
            
            var list: [DistrictStorageModel] = []
            for observed in internalResponse.observed {
                guard let district = internalResponse.allChanged.first(where: { $0.id == observed.districtId }) else { continue }
                list.append(district)
            }
            
            seal.fulfill(list)
        }
    }
    
    private func fetchChanged() -> Promise<[DistrictStorageModel]> {
        return Promise { seal in
            seal.fulfill(localStorage?.fetch().filter { $0.stateChanged } ?? [])
        }
    }
    
    private func fetch() -> Promise<DistrictResponseModel> {
        return Promise { seal in
            self.provider.request(.fetch) { result in
                switch result {
                case let .success(response):
                    do {
                        seal.fulfill(try response.map(DistrictResponseModel.self))
                    } catch {
                        seal.reject(error)
                    }
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private func store(response: DistrictResponseModel) -> Promise<Void> {
        console("✅ store time \(Date())")
        return Promise { seal in
            localStorage?.beginWrite()
            
            for (index, voivodeship) in response.voivodeships.enumerated() {
                let voivodeshipObject = VoivodeshipStorageModel(with: voivodeship, index: index, updatedAt: response.updated)
                localStorage?.append(voivodeshipObject, policy: .all)
                
                for (districtIndex, district) in voivodeship.districts.enumerated() {
                    let existingDistrictObject: DistrictStorageModel? = localStorage?.fetch(primaryKey: district.id)
                    let districtObject = DistrictStorageModel(
                        with: district,
                        currentModel: existingDistrictObject,
                        voivodeship: voivodeshipObject,
                        index: districtIndex,
                        updatedAt: response.updated
                    )
                    
                    localStorage?.append(districtObject, policy: .all)
                }
            }
            
            do {
                try localStorage?.commitWrite()
                seal.fulfill(())
            } catch {
                seal.reject(error)
            }
        }
        
    }
    
    private func getAll() -> Promise<[VoivodeshipStorageModel]> {
        return Promise { seal in
            seal.fulfill(localStorage?.fetch() ?? [])
        }
    }
    
    private func clearDistrictsIfNeeded(response: DistrictResponseModel) -> Promise<DistrictResponseModel> {
        return Promise { seal in
            if response.voivodeships.count > .zero {
                let allVoivodeships: [VoivodeshipStorageModel] = localStorage?.fetch() ?? []
                let allDistricts: [DistrictStorageModel] = localStorage?.fetch() ?? []
                
                localStorage?.remove(allVoivodeships)
                localStorage?.remove(allDistricts)
            }
            
            seal.fulfill(response)
        }
    }
}

extension DistrictService {
    private func allDistrictsJSONFailure() -> Promise<Response> {
        return Promise { seal in
            let responseModel = DistrictsPWAResponseModel(result: .failed, updated: .zero, voivodeships: [])
            seal.fulfill(.init(allDistrictsJSON: encodeToJSON(responseModel), observedJSON: nil, changedObserved: []))
        }
    }
    
    private func allDistrictsJSON(internalresponse: InternalResponse) -> Promise<String?> {
        typealias DistrictModel = DistrictsPWAResponseModel.Voivodeship.District
        typealias VoivodeshipModel = DistrictsPWAResponseModel.Voivodeship
        
        return Promise { seal in
            var updateTimestamp: Int = .zero
            let allVoivodeships: [VoivodeshipStorageModel] = (localStorage?.fetch() ?? []).sorted { $0.order < $1.order }
            var voivodeshipModels: [VoivodeshipModel] = []
            for voivodeship in allVoivodeships {
                if updateTimestamp == .zero {
                    updateTimestamp = voivodeship.updatedAt
                }
                var districtModels: [DistrictModel] = []
                let sortedDistricts = voivodeship.districts.sorted { $0.order < $1.order }
                for district in sortedDistricts {
                    let isSubscribed = internalresponse.observed.first(where: { $0.districtId == district.id }) != nil
                    let districtModel: DistrictModel = .init(id: district.id, name: district.name, state: district.state, isSubscribed: isSubscribed)
                    districtModels.append(districtModel)
                }
                
                let voivodeshipModel: VoivodeshipModel = .init(id: voivodeship.id, name: voivodeship.name, districts: districtModels)
                voivodeshipModels.append(voivodeshipModel)
            }
            
            let responseModel = DistrictsPWAResponseModel(result: .success, updated: updateTimestamp, voivodeships: voivodeshipModels)
            
            seal.fulfill(encodeToJSON(responseModel))
        }
    }
    
    private func observedJSON(internalresponse: InternalResponse) -> Promise<String?> {
        typealias DistrictModel = ObservedDistrictsPWAResponseModel.District
        return Promise { seal in
            var observedDistricts: [DistrictModel] = []
            for observed in internalresponse.observed {
                guard let district: DistrictStorageModel = localStorage?.fetch(primaryKey: observed.districtId) else { continue }
                let districtResponseModel = DistrictModel(id: observed.districtId, name: observed.name, state: district.state)
                observedDistricts.append(districtResponseModel)
            }
            
            let response = ObservedDistrictsPWAResponseModel(districts: observedDistricts)
            
            seal.fulfill(encodeToJSON(response))
        }
    }
    
    private func encodeToJSON<T>(_ encodable: T) -> String? where T: Encodable {
        do {
            let data = try JSONEncoder().encode(encodable)
            return String(data: data, encoding: .utf8)
        } catch {
            console(error)
            return nil
        }
    }
}
