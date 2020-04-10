enum ValidationType {
    case phoneNumber
    var regex: String {
        switch self {
        case .phoneNumber:
            return "^\\\(Constants.Networking.phoneNumberPrefix)[0-9]{9}$"
        }
    }

    var error: ValidationError {
        switch self {
        case .phoneNumber:
            return .invalidPhoneNumber
        }
    }
}
