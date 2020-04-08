import Foundation
import RxSwift
import RxCocoa
import Mimus
@testable import ProteGO

final class GcpClientMock: GcpClientType, Mock {

    var storage: [RecordedCall] = []

    var registerDeviceResult: Result<RegisterDeviceResponse, Error> = .failure(ErrorInfo("not initialized"))

    var confirmRegistrationResult: Result<ConfirmRegistrationResponse, Error> = .failure(ErrorInfo("not initialized"))

    var getStatusResult: Result<GetStatusResponse, Error> = .failure(ErrorInfo("not initialized"))

    var sendHistoryResult: Result<SendHistoryResponse, Error> = .failure(ErrorInfo("not initialized"))

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResponse, Error>> {
        recordCall(withIdentifier: "registerDevice", arguments: [msisdn])
        return .just(self.registerDeviceResult)
    }

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResponse, Error>> {
        recordCall(withIdentifier: "confirmRegistration", arguments: [code])
        return .just(self.confirmRegistrationResult)
    }

    func getStatus(lastBeaconDate: Date?) -> Single<Result<GetStatusResponse, Error>> {
        recordCall(withIdentifier: "getStatus", arguments: [lastBeaconDate])
        return .just(self.getStatusResult)
    }

    func sendHistory(encounters: [Encounter]) -> Single<Result<SendHistoryResponse, Error>> {
        recordCall(withIdentifier: "sendHistory", arguments: encounters)
        return .just(self.sendHistoryResult)
    }
}
