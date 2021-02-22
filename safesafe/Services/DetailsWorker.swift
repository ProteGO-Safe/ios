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

    private let decoder: JSONDecoder
    private let detailsProvider: MoyaProvider<DetailsTarget>
    private let timestampsWorker: TimestampsWorkerType
    private let fileStorage: FileStorageType

    //MARK: - Initialization

    init(
        detailsProvider: MoyaProvider<DetailsTarget>,
        timestampsWorker: TimestampsWorkerType,
        fileStorage: FileStorageType,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.detailsProvider = detailsProvider
        self.timestampsWorker = timestampsWorker
        self.fileStorage = fileStorage
        self.decoder = decoder
    }

    //MARK: - DetailsWorkerType

    @discardableResult func fetchData() -> Promise<String> {
        timestampsWorker.fetchTimestamps()
            .map { $0.detailsUpdated < Int(Date().timeIntervalSince1970) }
            .then(getData(shouldDownload:))
            .then(toString)
    }

    //MARK: - Private methods

    private func getData(shouldDownload: Bool) -> Promise<Data> {
        if shouldDownload {
            return detailsProvider.request(.fetch)
                .map { $0.data }
                .then(updateLocalData(responseData:))
        } else {
            return self.fileStorage
                .read(from: .details)
                .toPromise()
        }
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
