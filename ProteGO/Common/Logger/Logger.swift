import Foundation
#if canImport(BugfenderSDK)
import BugfenderSDK
#endif
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

let logger = Logger.shared

final class Logger {

    static let shared = Logger()

    static let loggingPrefixes = [
        LogLevel.debug: "💙 Debug",
        LogLevel.info: "💚 Info",
        LogLevel.warning: "💛 Warn",
        LogLevel.error: "❤️ Error"
    ]

    var bugfenderSessionIdentifier: String {
        #if canImport(BugfenderSDK)
        return Bugfender.sessionIdentifierUrl()?.absoluteString ?? "n/a \(UUID().uuidString)"
        #else
        return ""
        #endif
    }

    private var isCrashlyticsEnabled = false

    private var isBugFenderEnabled = false

    private var isConsoleLoggingEnabled = false

    private var isRunInSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private init() {
        if !isRunInSimulator,
            let bugfenderEnabled = Constants.InfoKeys.bugfenderEnabled.value,
            let bugfenderKey = Constants.InfoKeys.bugfenderKey.value,
            bugfenderEnabled == "true" {
            self.activateBugfender(appKey: bugfenderKey)
        }

        if let consoleEnabled = Constants.InfoKeys.consoleLoggingEnabled.value,
            consoleEnabled == "true" {
            self.isConsoleLoggingEnabled = true
        }

        if let crashlyticsEnabled = Constants.InfoKeys.crashlyticsEnabled.value,
            crashlyticsEnabled == "true" {
            self.isCrashlyticsEnabled = true
        }
    }

    func debug(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(.debug, message, file, function, line)
    }

    func info(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(.info, message, file, function, line)
    }

    func warning(_ message: String, _ file: String = #file,
                 _ function: String = #function, _ line: Int = #line) {
        log(.warning, message, file, function, line)
    }

    func error(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(.error, message, file, function, line)
    }

    private func log(_ level: LogLevel, _ message: String, _ file: String = #file,
                     _ function: String = #function, _ line: Int = #line) {
        #if canImport(BugfenderSDK)
        if self.isBugFenderEnabled {
            Bugfender.log(lineNumber: line,
                          method: function,
                          file: file,
                          level: level.bugfenderLevel,
                          tag: self.bugfenderSessionIdentifier,
                          message: message)

        }
        #endif

        #if canImport(FirebaseCrashlytics)
        if self.isCrashlyticsEnabled {
            Crashlytics.crashlytics().log(message)
        }
        #endif

        if self.isConsoleLoggingEnabled {
            NSLog("\(Logger.loggingPrefixes[level] ?? ""): \(message)")
        }
    }

    private func activateBugfender(appKey: String) {
        #if canImport(BugfenderSDK)
        Bugfender.setPrintToConsole(false)
        Bugfender.activateLogger(appKey)
        Bugfender.enableUIEventLogging()
        Bugfender.enableCrashReporting()

        self.isBugFenderEnabled = true
        #endif
    }
}
