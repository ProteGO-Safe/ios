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

    //MARK: - Properties

    weak var delegate: DashboardWorkerDelegate?
    private let dashboardProvider: MoyaProvider<DashboardTarget>
    private let timestampsWorker: TimestampsWorkerType
    private let fileStorage: FileStorageType
    private let decoder:JSONDecoder
    private let getCurrentDate: () -> Date

    //MARK: - Initialization

    init(
        dashboardProvider: MoyaProvider<DashboardTarget>,
        timestampsWorker: TimestampsWorkerType,
        fileStorage: FileStorageType,
        decoder: JSONDecoder = JSONDecoder(),
        getCurrentDate: @escaping () -> Date = Date.init
    ) {
        self.dashboardProvider = dashboardProvider
        self.timestampsWorker = timestampsWorker
        self.fileStorage = fileStorage
        self.decoder = decoder
        self.getCurrentDate = getCurrentDate
    }

    //MARK: - DashboardWorkerType

    func fetchData(shouldDelegateResult: Bool = false) -> Promise<String> {
        timestampsWorker.fetchTimestamps()
            .map { $0.dashboardUpdated < Int(self.getCurrentDate().timeIntervalSince1970) }
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
        let items = objects.compactMap { object -> (DashboardStatsAPIResponse, Data)? in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed),
                  let item = try? decoder.decode(DashboardStatsAPIResponse.self, from: jsonData) else {
                console("Wrong covidStats object: \(object)", type: .error)
                return nil
            }
            return (item, jsonData)
        }
        .sorted(by: { $0.0.updated > $1.0.updated})
        .map { $0.1 }

        guard let firstItem = items.first else {
            return .init(error: InternalError.nilValue)
        }
        
        return updateLocalData(responseData: firstItem)
            .asVoid()
    }

    //MARK: - Private methods

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
}
