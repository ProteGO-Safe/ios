import Foundation
import RxSwift
import RxCocoa
import Mimus
@testable import ProteGO

final class GcpClientMock: GcpClientType, Mock {

    var storage: [RecordedCall] = []

    var registerDeviceResult: Result<RegisterDeviceResponse, Error> = .failure(ErrorInfo("not initialized"))

    var confirmRegistrationResult: Result<ConfirmRegistrationResponse, Error> = .failure(ErrorInfo("not initialized"))

    var registerNoMsisdnResult: Result<RegisterNoMsisdnResponse, Error> = .failure(ErrorInfo("not initialized"))

    var getStatusResult: Result<GetStatusResponse, Error> = .failure(ErrorInfo("not initialized"))

    var sendHistoryResult: Result<SendHistoryResponse, Error> = .failure(ErrorInfo("not initialized"))

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResponse, Error>> {
        recordCall(withIdentifier: "registerDevice", arguments: [msisdn])
        return .just(self.registerDeviceResult)
    }

    func registerNoMsisdn() -> Single<Result<RegisterNoMsisdnResponse, Error>> {
        recordCall(withIdentifier: "registerNoMsisdn")
        return .just(self.registerNoMsisdnResult)
    }

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResponse, Error>> {
        recordCall(withIdentifier: "confirmRegistration", arguments: [code])
        return .just(self.confirmRegistrationResult)
    }

    func getStatus(lastBeaconDate: Date?) -> Single<Result<GetStatusResponse, Error>> {
        recordCall(withIdentifier: "getStatus", arguments: [lastBeaconDate])
        return .just(self.getStatusResult)
    }

    func sendHistory(confirmCode: String, encounters: [Encounter]) -> Single<Result<SendHistoryResponse, Error>> {
        recordCall(withIdentifier: "sendHistory", arguments: [confirmCode, encounters])
        return .just(self.sendHistoryResult)
    }
}
