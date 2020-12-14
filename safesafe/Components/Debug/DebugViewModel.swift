//
//  DebugViewModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 18/08/2020.
//

import Foundation
import ZIPFoundation

enum AnalyzeDay: String, Hashable {
    case tenDaysAgo
    case twoDaysAgo
    case yesterday
    case today
}

enum DebugAction {
    case none
    case uploadedPayloadsShare
    case uploadedPayloadsPreview
    case logsShare
    case dumpLocalstorage
    case downloadDistricts
    case simulateExposureRisk
    case deleteSimulatedExposures
    case simulateRiskCheck
    case deleteSimulatedRiskCheck
}

protocol DebugViewModelDelegate: class {
    func sharePayloads(fileURL: URL)
    func shareLogs(fileURL: URL)
    func showTextPreview(text: String)
    func showLocalStorageFiles(list: [String])
    func showSimulatedRisksSheet(list: [RiskLevel: String])
    func showAnalyzeDaysSheet(list: [AnalyzeDay: String])
}

final class DebugViewModel: ViewModelType {
    weak var delegate: DebugViewModelDelegate?
    private lazy var sqliteManager = SQLiteManager()
    private weak var districtService: DebugDistrictServicesProtocol?
    private weak var localStorage: LocalStorageProtocol?
    private var onSimulateExposureRiskChangeClosure: (() -> Void)?
    
    enum Texts {
        static let title = "Debug"
        static let previewTitle = "Preview"
        static let noUploadedPayloadsTitle = "No Uploaded Payloads Yet"
        static let shareUploadedPayloadsTitle = "Share Uploaded Payloads"
        static let noLogsTitle = "Nothing logged yet"
        static let shareLogsTitle = "Share Logs"
        static let dumpLocalStorageTitl = "Dump Local Storage"
        static let downloadDistrictsTitle = "Download districts"
        static let simulateExposureRiskTitle = "Simulate exposure risk"
        static let deleteSimulatedExposuresTitle = "Delete simulated exposures"
        static let simulateRiskCheckTitle = "Simulate risk check"
        static let deleteSimulatedRiskCheck = "Delete simulated risk check"
    }
    
    var numberOfPayloads: Int {
        do {
            let dirContent = try FileManager.default.contentsOfDirectory(atPath: try Directory.uploadedPayloads().path)
            return dirContent.count
        } catch {
            console(error, type: .error)
        }
        return .zero
    }
    
    var logExists: Bool {
        do {
            let dirContent = try FileManager.default.contentsOfDirectory(atPath: try Directory.logs().path)
            return dirContent.count != .zero
        } catch {
            console(error, type: .error)
        }
        return false
    }
    
    init(
        districtService: DebugDistrictServicesProtocol,
        localStorage: LocalStorageProtocol?
    ) {
        
        self.districtService = districtService
        self.localStorage = localStorage
    }
    
    func manage(debugAction: DebugAction) {
        switch debugAction {
        case .uploadedPayloadsShare:
            guard let url = try? File.uploadedPayloadsZIP() else { return }
            delegate?.sharePayloads(fileURL: url)
        case .logsShare:
            guard let url = try? File.logFileURL() else { return }
            delegate?.shareLogs(fileURL: url)
        case .dumpLocalstorage:
            let list = localStorageFiles()
            guard !list.isEmpty else { return }
            
            delegate?.showLocalStorageFiles(list: list)
        case .downloadDistricts:
            districtService?.foceFetchDistricts()
        case .simulateExposureRisk:
            delegate?.showSimulatedRisksSheet(list: [.low: "Low risk", .medium: "Medium risk", .high: "High risk"])
        case .deleteSimulatedExposures:
            deleteSimulatedExposures()
        case .simulateRiskCheck:
            delegate?.showAnalyzeDaysSheet(list: [.tenDaysAgo: "10 days ago", .twoDaysAgo: "2 days ago", .yesterday: "yesterday", .today: "now"])
        case .deleteSimulatedRiskCheck:
            deleteSimulatedRiskCheck()
        default: ()
        }
    }
    
    func openLocalStorage(with name: String) {
        delegate?.showTextPreview(text: sqliteManager.read(fileName: name))
    }
    
    func simulateRiskCheck(day: AnalyzeDay) {
        guard let date = date(for: day) else { return }
        
        let matchedKeyCountRandom = (0...10).randomElement() ?? .zero
        let keysCountRandom = (10...10_000).randomElement() ?? 10
        
        localStorage?.beginWrite()
        
        let riskModel = ExposureHistoryAnalyzeCheck(matchedKeyCount: matchedKeyCountRandom, keysCount: keysCountRandom)
        riskModel.date = date
        riskModel.id = "debug_\(UUID().uuidString)"
        
        localStorage?.append(riskModel)
       
        try? localStorage?.commitWrite()
        
        ExposureHistoryRiskCheckAgregated.update(with: riskModel, debug: true, storage: localStorage)
    }
    
    func deleteSimulatedRiskCheck() {
        guard
            let riskChecks: [ExposureHistoryAnalyzeCheck] = localStorage?.fetch(),
            let agregatedDayCheck: [ExposureHistoryDayCheck] = localStorage?.fetch()
        else { return }
        
        let debugRiskChecks = riskChecks.filter { $0.id.hasPrefix("debug_") }
        let debugDayChecks = agregatedDayCheck.filter { $0.id.hasPrefix("debug_") }
        
        localStorage?.beginWrite()
        
        for riskCheck in debugRiskChecks {
            localStorage?.remove(riskCheck, completion: nil)
        }
        
        for dayCheck in debugDayChecks {
            localStorage?.remove(dayCheck, completion: nil)
        }
        
        try? localStorage?.commitWrite()
    }
    
    func simulateExposureRisk(riskLevel: RiskLevel) {
        var risk: Int = .zero
        switch riskLevel {
        case .low:
            risk = 1400
        case .medium:
            risk = 2900
        case .high:
            risk = 4000
        default: ()
        }
    
        localStorage?.beginWrite()
        
        let date = Date()
        let exposure = Exposure()
        exposure.date = date
        exposure.id = "debug_\(Int(date.timeIntervalSince1970))"
        exposure.risk = risk
        
        localStorage?.append(exposure)
        
        let matchedKeyCountRandom = (0...10).randomElement() ?? .zero
        let exposureHistoryModel = ExposureHistoryRiskCheck(matchedKeyCount: matchedKeyCountRandom, riskLevelFull: risk)
        exposureHistoryModel.date = date
        exposureHistoryModel.id = "debug_\(UUID().uuidString)"
        localStorage?.append(exposureHistoryModel)
        
        try? localStorage?.commitWrite()
        
        onSimulateExposureRiskChangeClosure?()
    }
    
    func onSimulateExposureRiskChange(_ closure: @escaping () -> Void) {
        onSimulateExposureRiskChangeClosure = closure
    }
    
    private func deleteSimulatedExposures() {
        guard let exposures: [Exposure] = localStorage?.fetch() else { return }
        let debugExposures = exposures.filter { $0.id.hasPrefix("debug_") }
        
        localStorage?.beginWrite()
        
        for exposure in debugExposures {
            localStorage?.remove(exposure, completion: nil)
        }
        
        try? localStorage?.commitWrite()
        
        onSimulateExposureRiskChangeClosure?()
    }
    
    private func localStorageFiles() -> [String] {
        do {
            let dirURL = try Directory.webkitLocalStorage()
            let dirContent = try FileManager.default.contentsOfDirectory(atPath: dirURL.path).filter({ $0.hasSuffix("localstorage")})
            
            return dirContent
            
        } catch { console(error, type: .error) }
        
        return []
    }
    
    private func date(for analyzeDay: AnalyzeDay) -> Date? {
        switch analyzeDay {
        
        case .tenDaysAgo:
            return Calendar.current.date(byAdding: .day, value: -10, to: Date())
        case .twoDaysAgo:
            return Calendar.current.date(byAdding: .day, value: -2, to: Date())
        case .yesterday:
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        case .today:
            return Date()
        }
    }
}
