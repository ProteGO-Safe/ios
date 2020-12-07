//
//  HistoricalDataWorker.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 07/12/2020.
//

import Foundation
import PromiseKit

struct HistoricalData: Encodable {
    let notifications: [PushNotificationHistoryModel.EncodableModel]
    let riskChecks: [ExposureHistoryAnalyzeCheck.EncodableModel]
    let exposures: [ExposureHistoryRiskCheck.EncodableModel]
}

protocol HistoricalDataWorkerType {
    func getData() -> Promise<HistoricalData>
    func clearData() -> Promise<Void>
}


final class HistoricalDataWorker: HistoricalDataWorkerType {
    
    private let notificationsHistoryWorker: NotificationHistoryWorkerType
    private let exposureHistoricalDataService: ExposureServiceHistoricalDataProtocol
    
    init(
        notificationsHistoryWorker: NotificationHistoryWorkerType,
        exposureHistoricalDataService: ExposureServiceHistoricalDataProtocol
    ) {
        self.notificationsHistoryWorker = notificationsHistoryWorker
        self.exposureHistoricalDataService = exposureHistoricalDataService
    }
    
    func getData() -> Promise<HistoricalData> {
        return notificationsHistoryWorker
            .fetchAllNotifications()
            .then { notifications in
                return self.exposureHistoricalDataService.getHistoricalRiskCheck().map { (notifications, $0) }
            }
            .then { notifications, riskCheck in
                self.exposureHistoricalDataService.getHistoricalAnalyzeCheck().map { (notifications, riskCheck, $0) }
            }
            .then { notifications, riskCheck, analyzeCheck -> Promise<HistoricalData> in
                return .value(
                    .init(
                        notifications: notifications.map { $0.asEncodable() },
                        riskChecks: analyzeCheck.map { $0.asEncodable() },
                        exposures: riskCheck.map { $0.asEncodable() }
                    )
                )
            }
        
    }
    
    func clearData() -> Promise<Void> {
        notificationsHistoryWorker
            .clearHistory()
            .then {
                self.exposureHistoricalDataService.clearHistoricalData()
            }
    }
}
