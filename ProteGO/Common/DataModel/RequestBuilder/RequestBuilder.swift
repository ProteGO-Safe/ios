import Foundation

final class RequestBuilder: RequestBuilderType {

    private let registrationManager: RegistrationManagerType

    init(registrationManager: RegistrationManagerType) {
        self.registrationManager = registrationManager
    }

    func registerDeviceRequest(msisdn: String) -> RegisterDeviceRequest {
        var debugSendSms: Bool?
        if DebugMenu.assign(DebugMenu.registrationDebugNoSms) {
            debugSendSms = false
        }
        return RegisterDeviceRequest(msisdn: msisdn, debugSendSms: debugSendSms)
    }

    func confirmRegistrationRequest(code: String) -> ConfirmRegistrationRequest? {
        var code = code
        if DebugMenu.assign(DebugMenu.registrationDebugNoSms) {
            code = registrationManager.debugRegistrationCode ?? ""
        }
        guard let registrationId = registrationManager.registrationId else {
            return nil
        }
        return ConfirmRegistrationRequest(code: code, registrationId: registrationId)
    }
}
