enum ValidationError: Error {
    case invalidPhoneNumber
    var message: String {
        switch self {
        case .invalidPhoneNumber:
            return ""
            // TODO: - Error text
//            return L10n.
        }
    }
}
