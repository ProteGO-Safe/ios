enum ValidationError: Error {
    case invalidPhoneNumber
    var message: String {
        switch self {
        default:
            return ""
        }
    }
}
