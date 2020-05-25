//
//  ExposureSummaryService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

protocol ExposureSummaryServiceProtocol {
    
    func getExposureSummary() -> ExposureSummary
    
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
    
    func getExposureSummary() -> ExposureSummary {
        // If there are no exposures by now, return lowest risk
        guard let highestRisk = getSanitizedExposures()
            .sorted(by: { $0.risk > $1.risk })
            .first?
            .risk
        else {
            return ExposureSummary(riskLevel: .low)
        }
        
        return ExposureSummary(fromFullRangeScore: highestRisk) ?? ExposureSummary(riskLevel: .low)
    }
    
    // MARK: - Private methods
    
    /// Removes expired data from local storage.
    /// Returns exposures sorted by timestamp.
    private func getSanitizedExposures() -> [Exposure] {
        var exposures: [Exposure] = storageService.fetch()
            .sorted(by: { $0.date < $1.date })

        let expirationBoundary = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(Constants.dataExpirationSeconds))
        var expiredExposures = [Exposure]()
        
        while (exposures.first?.date ?? expirationBoundary) < expirationBoundary {
            if let exposure = exposures.first {
                exposures.removeFirst()
                expiredExposures.append(exposure)
            }
        }
        // TODO: Remove expiredExposures from realm

        return exposures
    }
    
}
