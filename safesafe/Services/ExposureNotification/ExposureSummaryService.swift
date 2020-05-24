//
//  ExposureSummaryService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

protocol ExposureSummaryServiceProtocol {
    
    func getExposureSummary() -> [DaySummary]
    
}

final class ExposureSummaryService: ExposureSummaryServiceProtocol {
    
    private enum Constants {
        static let exposureDurationBoundaryMinutes = 16.0
        static let exposureDurationBoundarySeconds = Constants.exposureDurationBoundaryMinutes * 60
        static let dataExpirationDays = 14.0
        static let dataExpirationSeconds = Constants.dataExpirationDays * 86400
        static let minRiskScore = 0.0
        static let maxRiskScore = 4096.0
        static let minNormalizedRiskScore = 1.0
        static let maxNormalizedRiskScore = 8.0
    }
    
    // MARK: - Properties
    
    private let storageService: LocalStorageProtocol
    
    // MARK: - Lice Cycle
    
    init(storageService: LocalStorageProtocol) {
        self.storageService = storageService
    }
    
    // MARK: - Public methods
    
    func getExposureSummary() -> [DaySummary] {
        Dictionary(
            grouping: getSanitizedExposures(),
            by: { Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: $0.timestamp)) }
        ).compactMap { (_, exposures) -> DaySummary? in
            // In each iteration we have a pair of `day` and `exposures made that day`
            
            guard let exposureDayTimestamp = exposures.first?.timestamp else {
                return nil
            }
            
            let exposureTimeSum = exposures
                .map { $0.duration }
                .reduce(0, +)
            
            if exposureTimeSum >= Constants.exposureDurationBoundarySeconds {
                return DaySummary(date: Int(exposureDayTimestamp), riskScore: Int(Constants.maxNormalizedRiskScore))
            } else {
                let riskSum = exposures
                    .map { $0.risk }
                    .reduce(0, +)
                let riskValue = max(Double(riskSum), Constants.maxRiskScore)
                
                // Linear transformation from 0-4096 to 1-8
                let a = (Constants.maxNormalizedRiskScore - Constants.minNormalizedRiskScore) / (Constants.maxRiskScore - Constants.minRiskScore)
                let b = Constants.maxNormalizedRiskScore - a * Constants.maxRiskScore
                let normalizedRisk = a * riskValue + b
                
                return DaySummary(date: Int(exposureDayTimestamp), riskScore: Int(normalizedRisk))
            }
        }
    }
    
    // MARK: - Private methods
    
    private func normalizedRiskValue(for exposures: [Exposure]) -> Int {
        return 0
    }
    
    /// Removes expired data from local storage.
    /// Returns exposures sorted by timestamp.
    private func getSanitizedExposures() -> [Exposure] {
        let exposures: [Exposure] = storageService.fetch()
            .sorted(by: { $0.timestamp < $1.timestamp })
        
        let expirationBoundary = Date().timeIntervalSince1970 - Double(Constants.dataExpirationSeconds)
        while (exposures.first?.timestamp ?? expirationBoundary) < expirationBoundary {
            // TODO: Remove exposure from storage
        }
        
        return exposures
    }
    
}
