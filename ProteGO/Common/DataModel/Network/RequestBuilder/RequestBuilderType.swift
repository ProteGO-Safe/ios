import Foundation

protocol RequestBuilderType {

    func registerDeviceRequest(msisdn: String) -> RegisterDeviceRequest

    func confirmRegistrationRequest(code: String) -> ConfirmRegistrationRequest?

    func registerNoMsisdnRequest() -> RegisterNoMsisdnRequest

    func getStatusRequest(lastBeaconDate: Date?) -> GetStatusRequest?

    func sendHistoryRequest(confirmCode: String, encounters: [Encounter]) -> SendHistoryRequest?
}
