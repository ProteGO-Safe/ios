import Foundation

protocol ProteGOError: LocalizedError {
}

struct ErrorInfo: ProteGOError {
    let description: String

    var errorDescription: String {
        return description
    }

    init(_ description: String) {
        self.description = description
    }
}

enum InstanceError: ProteGOError {
    case destroyed(ErrorInfo)

    var errorDescription: String? {
        switch self {
        case .destroyed(let info):
            return info.description
        }
    }

    static func deallocated(_ file: String, _ line: Int) -> InstanceError {
        return InstanceError.destroyed(ErrorInfo("Deallocated file: \(file), line: \(line)"))
    }
}
