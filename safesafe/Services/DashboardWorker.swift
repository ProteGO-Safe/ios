//
//  DashboardWorker.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 11/12/2020.
//

import Foundation
import Moya
import PromiseKit

protocol DashboardWorkerDelegate: AnyObject {
    func onData(jsonString: String)
}

protocol DashboardWorkerType: AnyObject {
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
    private let timestampsWorker: TimestampsWorkerType
    private let localStorage: RealmLocalStorage?
    private let fileStorage: FileStorageType
    private let decoder = JSONDecoder()

    init(
        dashboardProvider: MoyaProvider<DashboardTarget>,
        timestampsWorker: TimestampsWorkerType,
        localStorage: RealmLocalStorage? = RealmLocalStorage(),
        fileStorage: FileStorageType = FileStorage()
    ) {
        self.dashboardProvider = dashboardProvider
        self.timestampsWorker = timestampsWorker
        self.localStorage = localStorage
        self.fileStorage = fileStorage
    }
    
    func fetchData(shouldDelegateResult: Bool = false) -> Promise<String> {
        timestampsWorker.fetchTimestamps()
            .map { $0.dashboardUpdated < Int(Date().timeIntervalSince1970) }
            .then(getDashboardData(shouldDownload:))
            .then(toString)
            .then { jsonString in
                self.delegateResultIfNeeded(
                    shouldDelegateResult: shouldDelegateResult,
                    jsonString: jsonString
                )
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
    
    private func downloadDashboardData() -> Promise<Data> {
        dashboardProvider.request(.fetch)
            .map { $0.data }
    }
    
    private func updateLocalData(responseData: Data) -> Promise<Data> {
        self.fileStorage
            .write(to: .dashboard, content: responseData)
            .map { responseData }
            .toPromise()
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
    
    private func toString(from data: Data) -> Promise<String> {
        Promise { seal in
            if let jsonString = String(data: data, encoding: .utf8) {
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

    private func getDashboardData(shouldDownload: Bool) -> Promise<Data> {
        if shouldDownload {
            return self.downloadDashboardData()
                .then(self.updateLocalData(responseData:))
        } else {
            return self.fileStorage
                .read(from: .dashboard)
                .toPromise()
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
