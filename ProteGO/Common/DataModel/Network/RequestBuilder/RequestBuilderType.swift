import Foundation

protocol RequestBuilderType {

    func registerDeviceRequest(msisdn: String) -> RegisterDeviceRequest

    func confirmRegistrationRequest(code: String) -> ConfirmRegistrationRequest?

    func getStatusRequest(lastBeaconDate: Date?) -> GetStatusRequest?

    func sendHistoryRequest(encounters: [Encounter]) -> SendHistoryRequest?
}
