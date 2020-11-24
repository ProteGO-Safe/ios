//
//  ExposureSummaryService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 24/05/2020.
//

import Foundation

protocol ExposureSummaryServiceProtocol: class {
    
    func getExposureSummary() -> ExposureSummary
    func clearExposureSummary() -> ExposureSummary
}

final class ExposureSummaryService: ExposureSummaryServiceProtocol {
    
    private enum Constants {
        static let dataExpirationDays = 14.0
        static let dataExpirationSeconds = Constants.dataExpirationDays * 86400
    }
    
    // MARK: - Properties
    
    private let storageService: LocalStorageProtocol?
    private let freeTestService: FreeTestService
    
    // MARK: - Lice Cycle
    
    init(
        storageService: LocalStorageProtocol?,
        freeTestService: FreeTestService) {
        
        self.storageService = storageService
        self.freeTestService = freeTestService
    }
    
    // MARK: - Public methods
    
    func getExposureSummary() -> ExposureSummary {
        // If there are no exposures by now, return lowest risk
        guard let highestRisk = getSanitizedExposures()
            .sorted(by: { $0.risk > $1.risk })
            .first?
            .risk
        else {
            freeTestService.deleteGUID()
            return ExposureSummary(riskLevel: .none)
        }
        
        let summary = ExposureSummary(fromFullRangeScore: highestRisk)
        
        if summary.riskLevel != .high {
            freeTestService.deleteGUID()
        }
        
        return summary
    }
    
    func clearExposureSummary() -> ExposureSummary {
        guard let allExposures: [Exposure] = storageService?.fetch() else {
            return getExposureSummary()
        }
        
        storageService?.beginWrite()
        
        storageService?.remove(allExposures, completion: nil)
        
        do {
            try storageService?.commitWrite()
            return getExposureSummary()
        } catch {
            console(error, type: .error)
            return getExposureSummary()
        }
    }
    
    // MARK: - Private methods
    
    /// Removes expired data from local storage.
    /// Returns exposures sorted by timestamp.
    private func getSanitizedExposures() -> [Exposure] {
        var exposures: [Exposure] = (storageService?.fetch() ?? []).sorted(by: { $0.date < $1.date })

        let expirationBoundary = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(Constants.dataExpirationSeconds))
        var expiredExposures = [Exposure]()
        
        while (exposures.first?.date ?? expirationBoundary) < expirationBoundary {
            if let exposure = exposures.first {
                exposures.removeFirst()
                expiredExposures.append(exposure)
            }
        }
        storageService?.remove(expiredExposures, completion: nil)

        return exposures
    }
    
}
