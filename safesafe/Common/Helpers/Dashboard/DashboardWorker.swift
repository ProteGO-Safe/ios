//
//  DashboardWorker.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 11/12/2020.
//

import Foundation
import Moya
import PromiseKit

protocol DashboardWorkerDelegate: class {
    func onData(jsonString: String)
}

protocol DashboardWorkerType {
    var delegate: DashboardWorkerDelegate? { get set }
    @discardableResult func fetchData(shouldDelegateResult: Bool) -> Promise<String>
    @discardableResult func parseSharedContainerCovidStats(objects: [[String : Any]]) -> Promise<Void>
}

extension DashboardWorkerType {
    func fetchData(shouldDelegateResult: Bool = false) -> Promise<String> {
        return fetchData(shouldDelegateResult: shouldDelegateResult)
    }
}

final class DashboardWorker: DashboardWorkerType {

    weak var delegate: DashboardWorkerDelegate?
    private let dashboardProvider: MoyaProvider<DashboardTarget>
    private let timestampsProvider: MoyaProvider<TimestampsTarget>
    private let localStorage: RealmLocalStorage?
    private let fileStorage: FileStorageType
    
    init(
        dashboardProvider: MoyaProvider<DashboardTarget>,
        timestampsProvider: MoyaProvider<TimestampsTarget>,
        localStorage: RealmLocalStorage? = RealmLocalStorage(),
        fileStorage: FileStorageType = FileStorage()
    ) {
        self.dashboardProvider = dashboardProvider
        self.timestampsProvider = timestampsProvider
        self.localStorage = localStorage
        self.fileStorage = fileStorage
    }
    
    func fetchData(shouldDelegateResult: Bool = false) -> Promise<String> {
        shouldDownload()
            .then { should -> Promise<String>  in
                if should {
                    return self.downloadData()
                        .then(self.updateData)
                        .then(self.toString)
                        .then {
                            self.delegateResultIfNeeded(shouldDelegateResult: shouldDelegateResult, jsonString: $0)
                        }
                } else {
                    switch self.fileStorage.read(from: .dashboard) {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        if let dashboard = try? decoder.decode(DashboardStatsAPIResponse.self, from: data) {
                            return self.toString(from: DashboardStatsModel.init(model: dashboard))
                                .then {
                                    self.delegateResultIfNeeded(shouldDelegateResult: shouldDelegateResult, jsonString: $0)
                                }
                        } else {
                            return .init(error: InternalError.nilValue)
                        }
                    case .failure(let error):
                        return .init(error: error)
                    }
                }
        }
    }
    
    func parseSharedContainerCovidStats(objects: [[String : Any]]) -> Promise<Void> {
        let decoder = JSONDecoder()
        let items = objects.compactMap { object -> PushNotificationCovidStatsModel? in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed),
                  let item = try? decoder.decode(PushNotificationCovidStatsModel.self, from: jsonData) else {
                console("Wrong covidStats object: \(object)", type: .error)
                return nil
            }
            return item
        }

        guard let recentlyUpdatedModel = items.sorted(by: { $0.updated > $1.updated }).first else {
            return .init(error: InternalError.nilValue)
        }
        
        return updateData(response: recentlyUpdatedModel).asVoid()
    }
    
    private func downloadData() -> Promise<Data> {
        return Promise { seal in
            dashboardProvider.request(.fetch) { result in
                switch result {
                case let .success(response):
                    seal.fulfill(response.data)
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private func updateData(responseData: Data) -> Promise<DashboardStatsModel> {
        Promise { seal in
            switch self.fileStorage.write(to: .dashboard, content: responseData) {
            case .success:
                let decoder = JSONDecoder()
                do {
                    let model = try decoder.decode(DashboardStatsAPIResponse.self, from: responseData)
                    seal.fulfill(.init(model: model))
                } catch let error {
                    seal.reject(error)
                }
            case .failure(let error):
                seal.reject(error)
            }
        }
    }
    
    private func updateData(response: PushNotificationCovidStatsModel) -> Promise<DashboardStatsModel> {
        Promise { seal in
            localStorage?.beginWrite()
            
            let shouldUpdate = shouldUpdateModel(with: response)
            
            let model: DashboardStatsModel
            if let dbModel: DashboardStatsModel = localStorage?.fetch(primaryKey: DashboardStatsModel.identifier) {
                model = dbModel
                if shouldUpdate {
                    model.update(with: response)
                }
            } else {
                if shouldUpdate {
                    model = DashboardStatsModel(model: response)
                } else {
                    model = DashboardStatsModel()
                }
            }
            model.lastFetch = Int(Date().timeIntervalSince1970)
            
            localStorage?.append(model, policy: .all)
            
            do {
                try localStorage?.commitWrite()
                seal.fulfill(model)
            } catch {
                seal.reject(error)
            }
        }
    }
    
    private func toString(from model: DashboardStatsModel) -> Promise<String> {
        return Promise { seal in
            let response = DashboardStatsResponse(covidStats: .init(with: model))
            if let jsonString = response.jsonString  {
                seal.fulfill(jsonString)
            } else {
                seal.reject(InternalError.nilValue)
            }
        }
    }
    
    private func delegateResultIfNeeded(shouldDelegateResult: Bool, jsonString: String) -> Promise<String> {
        if shouldDelegateResult {
            delegate?.onData(jsonString: jsonString)
        }
        
        return .value(jsonString)
    }
    
    private func shouldUpdateModel(with response: DashboardStatsAPIResponse) -> Bool {
        let recovered = response.newRecovered != nil && response.totalRecovered != nil
        let cases = response.newCases != nil && response.totalCases != nil
        let deaths = response.newDeaths != nil && response.totalDeaths != nil
        
        return recovered || cases || deaths
    }
    
    private func shouldUpdateModel(with response: PushNotificationCovidStatsModel) -> Bool {
        let recovered = response.newRecovered != nil && response.totalRecovered != nil
        let cases = response.newCases != nil && response.totalCases != nil
        let deaths = response.newDeaths != nil && response.totalDeaths != nil
        
        return recovered || cases || deaths
    }

    struct TimestampsResponse: Decodable {
        let nextUpdate: Int
        let dashboardUpdated: Int
        let detailsUpdated: Int
    }

    private func shouldDownload() -> Promise<Bool> {
        return Promise { seal in
            switch fileStorage.read(from: .timestamps) {
            case .success(let data):
                let decoder = JSONDecoder()
                guard let timestamps = try? decoder.decode(TimestampsResponse.self, from: data) else {
                    console("Can't parse timestamps data")
                    seal.fulfill(true)
                    return
                }
                if timestamps.nextUpdate < Int(Date().timeIntervalSince1970) {
                    self.downloadTimestamps()
                        .then(self.writeTimestampsToFile(data:))
                        .pipe { (result) in
                            switch result {
                            case .fulfilled(let shouldDownload):
                                seal.fulfill(shouldDownload)
                            case .rejected(let error):
                                seal.reject(error)
                            }
                        }
                } else {
                    seal.fulfill(false)
                }
            case .failure(let error):
                console(error)
                self.downloadTimestamps()
                    .then(self.writeTimestampsToFile(data:))
                    .pipe { (result) in
                        switch result {
                        case .fulfilled(let shouldDownload):
                            seal.fulfill(shouldDownload)
                        case .rejected(let error):
                            seal.reject(error)
                        }
                    }
            }
        }
    }



    private func downloadTimestamps() -> Promise<Data> {
        Promise { seal in
            timestampsProvider.request(.fetch) { result in
                switch result {
                case .success(let response):
                    seal.fulfill(response.data)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    private func writeTimestampsToFile(data: Data) -> Promise<Bool> {
        Promise { seal in
            switch self.fileStorage.write(to: .timestamps, content: data) {
            case .success:
                seal.fulfill(true)
            case .failure(let error):
                seal.reject(error)
            }
        }
    }

    
    private func update(lastFetch: Int) {
        localStorage?.beginWrite()
        
        let model: DashboardStatsModel
        if let dbModel: DashboardStatsModel = localStorage?.fetch(primaryKey: DashboardStatsModel.identifier) {
            model = dbModel
        } else {
            model = DashboardStatsModel()
        }
        
        model.lastFetch = lastFetch
        
        localStorage?.append(model, policy: .modified)
        
        do {
            try localStorage?.commitWrite()
        } catch {
            console(error, type: .error)
        }
    }
}
