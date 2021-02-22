//
//  TimestampsWorker.swift
//  safesafe
//
//  Created by Namedix on 22/02/2021.
//

import Foundation
import PromiseKit
import Moya

protocol TimestampsWorkerType: AnyObject {
    func fetchTimestamps() -> Promise<TimestampsResponse>
}

final class TimestampsWorker: TimestampsWorkerType {

    //MARK: - Properties

    private let decoder: JSONDecoder
    private let timestampsProvider: MoyaProvider<TimestampsTarget>
    private let fileStorage: FileStorageType

    //MARK: - Initialization

    init(
        timestampsProvider: MoyaProvider<TimestampsTarget>,
        fileStorage: FileStorageType,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.timestampsProvider = timestampsProvider
        self.fileStorage = fileStorage
        self.decoder = decoder
    }

    //MARK: - TimestampsWorkerType

    func fetchTimestamps() -> Promise<TimestampsResponse> {
        fileStorage.read(from: .timestamps)
            .toPromise()
            .then { data -> Promise<TimestampsResponse> in
                guard let timestamps = try? self.decoder.decode(TimestampsResponse.self, from: data),
                      timestamps.nextUpdate > Int(Date().timeIntervalSince1970) else {
                    return self.downloadAndSaveTimestamps()
                }
                return .init(error: InternalError.nilValue)
            }
            .recover { error -> Promise<TimestampsResponse> in
                console(error)
                return self.downloadAndSaveTimestamps()
            }
    }

    //MARK: - Private methods

    private func downloadAndSaveTimestamps() -> Promise<TimestampsResponse> {
        self.downloadTimestamps()
            .then(self.writeTimestampsToFile(data:))
            .then(self.decodeTimestamps(data:))
    }

    private func downloadTimestamps() -> Promise<Data> {
        timestampsProvider.request(.fetch)
            .map { $0.data }
    }

    private func writeTimestampsToFile(data: Data) -> Promise<Data> {
        fileStorage.write(to: .timestamps, content: data)
            .map { data }
            .toPromise()
    }

    private func decodeTimestamps(data: Data) -> Promise<TimestampsResponse> {
        guard let timestamps = try? self.decoder.decode(TimestampsResponse.self, from: data) else {
            console("Can't decode timestamps")
            return .init(error: InternalError.nilValue)
        }
        return .value(timestamps)
    }
}
