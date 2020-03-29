import Foundation

protocol AnnaError: LocalizedError {
}

struct ErrorInfo: AnnaError {
    let description: String

    var errorDescription: String {
        return description
    }

    init(_ description: String) {
        self.description = description
    }
}

enum InstanceError: AnnaError {
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
