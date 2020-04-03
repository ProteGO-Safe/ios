import Foundation

protocol RequestBuilderType {

    func registerDeviceRequest(msisdn: String) -> RegisterDeviceRequest

    func confirmRegistrationRequest(code: String) -> ConfirmRegistrationRequest?
}
