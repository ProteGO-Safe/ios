import Foundation
#if canImport(BugfenderSDK)
import BugfenderSDK
#endif

enum LogLevel {
    case debug
    case info
    case warning
    case error

    #if canImport(BugfenderSDK)
    var bugfenderLevel: BFLogLevel {
        switch self {
        case .debug: return .trace
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
    #endif
}
