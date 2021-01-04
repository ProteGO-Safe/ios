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
    
    private enum Constants {
        enum Download {
            // Discussion: downloading data from CDN is available only if DashboardStatsModel.updated timestamp is older than requestGap
            // then time intervals between next requests are not shorter than requestDebounce value
            static let requestGap: Int = 20 * 60 * 60
            static let requestDebounce: Int = 5 * 60
        }
    }
    
    weak var delegate: DashboardWorkerDelegate?
    private var dashboardStatsModel: DashboardStatsModel? { localStorage?.fetch().first }
    
    private let provider: MoyaProvider<CovidInfoTarget>
    private let localStorage: RealmLocalStorage?
    
    init(
        with provider: MoyaProvider<CovidInfoTarget>,
        localStorage: RealmLocalStorage? = RealmLocalStorage()
    ) {
        self.provider = provider
        self.localStorage = localStorage
    }
    
    func fetchData(shouldDelegateResult: Bool = false) -> Promise<String> {
        if shouldDownload() {
            return downloadData()
                .then(updateData)
                .then(toString)
                .then {
                    self.delegateResultIfNeeded(shouldDelegateResult: shouldDelegateResult, jsonString: $0)
                }
            
        } else {
            guard let model = dashboardStatsModel else {
                return .init(error: InternalError.nilValue)
            }
            
            return toString(from: model)
                .then {
                    self.delegateResultIfNeeded(shouldDelegateResult: shouldDelegateResult, jsonString: $0)
                }
        }
    }
    
    func parseSharedContainerCovidStats(objects: [[String : Any]]) -> Promise<Void> {
        let decoder = JSONDecoder()
        
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: objects, options: .fragmentsAllowed),
            let items = try? decoder.decode([PushNotificationCovidStatsModel].self, from: jsonData),
            let recentlyUpdatedModel = items.sorted(by: { $0.updated > $1.updated }).first
        else {
            return .init(error: InternalError.nilValue)
        }
        
        return updateData(response: recentlyUpdatedModel).asVoid()
    }
    
    private func downloadData() -> Promise<DashboardStatsAPIResponse> {
        return Promise { seal in
            provider.request(.fetch) { result in
                switch result {
                case let .success(response):
                    do {
                        let model = try response.map(DashboardStatsAPIResponse.self, atKeyPath: "covidStats")
                        seal.fulfill(model)
                    } catch {
                        seal.reject(error)
                    }
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private func updateData(response: DashboardStatsAPIResponse) -> Promise<DashboardStatsModel> {
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
    
    private func shouldDownload() -> Bool {
        let nowTimestamp = Int(Date().timeIntervalSince1970)
        guard let model = dashboardStatsModel else { return true }
        guard nowTimestamp - model.updated > Constants.Download.requestGap else { return false }
        guard nowTimestamp - model.lastFetch > Constants.Download.requestDebounce else {
            update(lastFetch: Int(Date().timeIntervalSince1970))
            return false
        }
        
        return true
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
