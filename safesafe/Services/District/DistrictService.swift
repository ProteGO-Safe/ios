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

protocol DebugDistrictServicesProtocol: class {
    func forceFetchDistricts(_ showNotification: Bool, delay: TimeInterval, completed: (() -> Void)?)
}

extension DebugDistrictServicesProtocol {
    func foceFetchDistricts(_ showNotification: Bool = true, delay: TimeInterval = 15, completed: (() -> Void)? = nil) {
        forceFetchDistricts(showNotification, delay: delay, completed: completed)
    }
}

final class DistrictService {
    
    struct Response {
        let allDistrictsJSON: String?
        let observedJSON: String?
        let all: [VoivodeshipStorageModel]
        let changedObserved: [DistrictStorageModel]
        let allChanged: [DistrictStorageModel]
        let observed: [ObservedDistrictStorageModel]
    }
    
    private struct InternalResponse {
        let all: [VoivodeshipStorageModel]
        let allChanged: [DistrictStorageModel]
        let observed: [ObservedDistrictStorageModel]
    }
    
    private let provider: MoyaProvider<CovidInfoTarget>
    private let localStorage: RealmLocalStorage?
    
    init(
        with provider: MoyaProvider<CovidInfoTarget>,
        localStorage: RealmLocalStorage? = RealmLocalStorage()
    ) {
        self.provider = provider
        self.localStorage = localStorage
        console("Local storage instance: \(String(describing: localStorage))")
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
            self.changedObserved(internalResponse: internalResponse).map {
                (allDistrictsJSON, observedJSON, internalResponse.all, internalResponse.allChanged, internalResponse.observed, $0)
            }
        }
        .then { allDistrictsJSON, observedJSON, all, allChanged, observed, changedObserved -> Promise<Response> in
            return .value(Response(
                allDistrictsJSON: allDistrictsJSON,
                observedJSON: observedJSON,
                all: all,
                changedObserved: changedObserved,
                allChanged: allChanged,
                observed: observed)
            )
        }
        .recover { error -> Promise<Response> in
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
    
    func hasDistricts() -> Promise<Bool> {
        return Promise { seal in
            guard let districts: [DistrictStorageModel] = localStorage?.fetch() else {
                return seal.fulfill(false)
            }
            
            return seal.fulfill(!districts.isEmpty)
        }
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
        console("📲 download districts")
        return Promise { seal in
            self.provider.request(.fetch) { result in
                switch result {
                case let .success(response):
                    do {
                        console("💚 download success")
                        seal.fulfill(try response.map(DistrictResponseModel.self))
                    } catch {
                        console("💔 Districts map - failure")
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
        console("voivodeships count: \(response.voivodeships.count)")
        console("update: \(response.voivodeshipsUpdated)")
        console("Local storage instance: \(String(describing: localStorage))")
        return Promise { seal in
            localStorage?.beginWrite()
            
            for (index, voivodeship) in response.voivodeships.enumerated() {
                let voivodeshipObject = VoivodeshipStorageModel(with: voivodeship, index: index, updatedAt: response.voivodeshipsUpdated)
                localStorage?.append(voivodeshipObject, policy: .all)
                
                for (districtIndex, district) in voivodeship.districts.enumerated() {
                    let existingDistrictObject: DistrictStorageModel? = localStorage?.fetch(primaryKey: district.id)
                    let districtObject = DistrictStorageModel(
                        with: district,
                        currentModel: existingDistrictObject,
                        voivodeship: voivodeshipObject,
                        index: districtIndex,
                        updatedAt: response.voivodeshipsUpdated
                    )
                    
                    localStorage?.append(districtObject, policy: .all)
                }
            }
            
            do {
                try localStorage?.commitWrite()
                console("✅ realm commit - success")
                seal.fulfill(())
            } catch {
                console("❌ can't commit changes to realm")
                seal.reject(error)
            }
        }
        
    }
    
    private func getAll() -> Promise<[VoivodeshipStorageModel]> {
        return Promise { seal in
            let allDistricts: [VoivodeshipStorageModel] = localStorage?.fetch() ?? []
            console("🔱 fetch all vovoidships count: \(allDistricts.count)")
            seal.fulfill(allDistricts)
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
            seal.fulfill(.init(
                allDistrictsJSON: encodeToJSON(responseModel),
                observedJSON: nil,
                all: [],
                changedObserved: [],
                allChanged: [],
                observed: []
                ))
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

extension DistrictService: DebugDistrictServicesProtocol {
    func forceFetchDistricts(_ showNotification: Bool = true, delay: TimeInterval = 15, completed: (() -> Void)? = nil) {
        perform()
            .done { response in
                completed?()
                guard let timestamp = response.all.first?.updatedAt else { return }
                
                NotificationManager.shared.showDistrictStatusLocalNotification(
                    with: response.allChanged,
                    observed: response.observed,
                    timestamp: timestamp,
                    delay: delay
                )
        }
        .catch { console($0, type: .error) }
    }
}
