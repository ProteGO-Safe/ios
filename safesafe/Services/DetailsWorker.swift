//
//  DetailsWorker.swift
//  safesafe
//
//  Created by Namedix on 22/02/2021.
//

import Foundation
import PromiseKit
import Moya

protocol DetailsWorkerType: AnyObject {
    @discardableResult func fetchData() -> Promise<String>
}

final class DetailsWorker: DetailsWorkerType {

    //MARK: - Properties

    private let detailsProvider: MoyaProvider<InfoTarget>
    private let timestampsWorker: TimestampsWorkerType
    private let fileStorage: FileStorageType
    private let decoder: JSONDecoder
    private let getCurrentDate: () -> Date

    //MARK: - Initialization

    init(
        detailsProvider: MoyaProvider<InfoTarget>,
        timestampsWorker: TimestampsWorkerType,
        fileStorage: FileStorageType,
        decoder: JSONDecoder = JSONDecoder(),
        getCurrentDate: @escaping () -> Date = Date.init
    ) {
        self.detailsProvider = detailsProvider
        self.timestampsWorker = timestampsWorker
        self.fileStorage = fileStorage
        self.decoder = decoder
        self.getCurrentDate = getCurrentDate
    }

    //MARK: - DetailsWorkerType

    @discardableResult func fetchData() -> Promise<String> {
        timestampsWorker.fetchTimestamps()
            .map { $0.detailsUpdated < Int(self.getCurrentDate().timeIntervalSince1970) }
            .then(getData(shouldDownload:))
            .then(toString)
    }

    //MARK: - Private methods

    private func getData(shouldDownload: Bool) -> Promise<Data> {
        if shouldDownload {
            return downloadAndCacheData()
        } else {
            return self.fileStorage
                .read(from: .details)
                .toPromise()
                .recover { [unowned self] error -> Promise<Data> in
                    console(error)
                    return self.downloadAndCacheData()
                }
        }
    }

    private func downloadAndCacheData() -> Promise<Data> {
        detailsProvider.request(.fetchDetails)
            .map { $0.data }
            .then(updateLocalData(responseData:))
    }

    private func updateLocalData(responseData: Data) -> Promise<Data> {
        self.fileStorage
            .write(to: .details, content: responseData)
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
}
