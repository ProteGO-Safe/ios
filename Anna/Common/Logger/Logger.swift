import Foundation
import BugfenderSDK
import FirebaseCrashlytics

public let logger = Logger.shared

public class Logger {

    static let shared = Logger()

    static let loggingPrefixes = [
        BFLogLevel.trace: "💙 Debug",
        BFLogLevel.info: "💚 Info",
        BFLogLevel.warning: "💛 Warn",
        BFLogLevel.error: "❤️ Error"
    ]

    public var bugfenderSessionIdentifier: String {
        return Bugfender.sessionIdentifierUrl()?.absoluteString ?? "n/a \(UUID().uuidString)"
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

    public func debug(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(.trace, message, file, function, line)
    }

    public func info(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(.info, message, file, function, line)
    }

    public func warning(_ message: String, _ file: String = #file,
                        _ function: String = #function, _ line: Int = #line) {
        log(.warning, message, file, function, line)
    }

    public func error(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(.error, message, file, function, line)
    }

    private func log(_ level: BFLogLevel, _ message: String, _ file: String = #file,
                     _ function: String = #function, _ line: Int = #line) {
        if self.isBugFenderEnabled {
            Bugfender.log(lineNumber: line,
                    method: function,
                    file: file,
                    level: level,
                    tag: self.bugfenderSessionIdentifier,
                    message: message)
        }

        if self.isConsoleLoggingEnabled {
            NSLog("\(Logger.loggingPrefixes[level] ?? ""): \(message)")
        }

        if self.isCrashlyticsEnabled {
            Crashlytics.crashlytics().log(message)
        }
    }

    private func activateBugfender(appKey: String) {
        Bugfender.activateLogger(appKey)
        Bugfender.enableUIEventLogging()
        Bugfender.enableCrashReporting()
        Bugfender.setPrintToConsole(false)

        self.isBugFenderEnabled = true
    }
}
