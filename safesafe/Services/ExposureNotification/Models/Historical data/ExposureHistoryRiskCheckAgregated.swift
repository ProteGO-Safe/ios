//
//  ExposureHistoryRiskCheckAgregated.swift
//  safesafe
//
//  Created by Łukasz Szyszkowski on 11/12/2020.
//

import Foundation
import RealmSwift

final class ExposureHistoryDayCheck: Object, LocalStorable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date = Date()
    @objc dynamic var keysCount: Int = .zero
    @objc dynamic var agregator: ExposureHistoryRiskCheckAgregated?
    
    override class func primaryKey() -> String? { "id" }
}

final class ExposureHistoryRiskCheckAgregated: Object, LocalStorable {
        
    static let identifier = "ExposureHistoryRiskCheckAgregated"
    
    @objc dynamic var id: String = ExposureHistoryRiskCheckAgregated.identifier
    @objc dynamic var lastRiskCheckTimestamp: Int = .zero
    @objc dynamic var todayKeysCount: Int = .zero
    @objc dynamic var last7daysKeysCount: Int = .zero
    @objc dynamic var totalKeysCount: Int = .zero
    let days = LinkingObjects(fromType: ExposureHistoryDayCheck.self, property: "agregator")
    
    override class func primaryKey() -> String? { "id" }
    
    static func update(with analyzeModel: ExposureHistoryAnalyzeCheck, debug: Bool = false, storage: LocalStorageProtocol? = nil) {
        let localStorage = storage ?? RealmLocalStorage()
        var daysCheck: [ExposureHistoryDayCheck] = localStorage?.fetch() ?? []
        
        let agregator:ExposureHistoryRiskCheckAgregated
        if let dbModel: ExposureHistoryRiskCheckAgregated = localStorage?.fetch().first {
            agregator = dbModel
        } else {
            agregator = ExposureHistoryRiskCheckAgregated()
        }
        
        let day = ExposureHistoryDayCheck()
        if debug {
            day.id = "debug_\(UUID().uuidString)"
        }
        day.keysCount = analyzeModel.keysCount
        day.date = analyzeModel.date
        day.agregator = agregator
        
        daysCheck.append(day)
        
        localStorage?.append(daysCheck, policy: .all, completion: nil)
        
        localStorage?.beginWrite()
        
        agregator.lastRiskCheckTimestamp = Int(analyzeModel.date.timeIntervalSince1970)
        agregator.todayKeysCount = analyzeModel.keysCount
        agregator.totalKeysCount += analyzeModel.keysCount
        agregator.last7daysKeysCount = last7DaysKeys(days: daysCheck)
        
        localStorage?.append(agregator, policy: .all)
        
        try? localStorage?.commitWrite()
        
        removeOldKeys(storage: storage)
    }
    
    private static func last7DaysKeys(days: [ExposureHistoryDayCheck]) -> Int {
        let now = Date()
        guard let sevenDaysBackDate = Calendar.current.date(byAdding: .day, value: -7, to: now) else { return .zero }
        let range = Calendar.current.startOfDay(for: sevenDaysBackDate)..<now
        let lastSevenDaysKeys = days.filter { range.contains($0.date) }.map { $0.keysCount }.reduce(Int.zero, +)
        
        return lastSevenDaysKeys
    }
    
    private static func removeOldKeys(storage: LocalStorageProtocol?) {
        let now = Date()
        guard
            let days: [ExposureHistoryDayCheck] = storage?.fetch(),
            let sevenDaysBackDate = Calendar.current.date(byAdding: .day, value: -7, to: now)
        else { return }
        
        let toRemove = Array(days.filter { $0.date < sevenDaysBackDate })
        storage?.remove(toRemove, completion: nil)
    }
}
