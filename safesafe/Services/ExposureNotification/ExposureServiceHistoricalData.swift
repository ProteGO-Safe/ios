//
//  ExposureServiceHistoricalData.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 07/12/2020.
//

import Foundation
import PromiseKit

protocol ExposureServiceHistoricalDataProtocol {
    func getHistoricalRiskCheck() -> Promise<[ExposureHistoryRiskCheck]>
    func getHistoricalAnalyzeCheck() -> Promise<[ExposureHistoryAnalyzeCheck]>
    func clearHistoricalData() -> Promise<Void>
}


final class ExposureServiceHistoricalData: ExposureServiceHistoricalDataProtocol {
    
    private let storageService: LocalStorageProtocol?
    
    init(storageService: LocalStorageProtocol?) {
        self.storageService = storageService
    }
    
    func getHistoricalRiskCheck() -> Promise<[ExposureHistoryRiskCheck]> {
        Promise { seal in
            let riskChecks: [ExposureHistoryRiskCheck] = (storageService?.fetch() ?? []).sorted { $0.date < $1.date }
            seal.fulfill(riskChecks)
        }
    }
    
    func getHistoricalAnalyzeCheck() -> Promise<[ExposureHistoryAnalyzeCheck]> {
        Promise { seal in
            let analyzeChecks: [ExposureHistoryAnalyzeCheck] = (storageService?.fetch() ?? []).sorted { $0.date < $1.date }
            seal.fulfill(analyzeChecks)
        }
    }
    
    func clearHistoricalData() -> Promise<Void> {
        Promise { seal in
            let analyzeChecks: [ExposureHistoryAnalyzeCheck] = (storageService?.fetch() ?? [])
            let riskChecks: [ExposureHistoryRiskCheck] = (storageService?.fetch() ?? [])
            
            storageService?.remove(analyzeChecks, completion: nil)
            storageService?.remove(riskChecks, completion: nil)
            
            seal.fulfill(())
        }
    }
}
