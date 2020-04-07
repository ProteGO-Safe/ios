import Foundation
import RxSwift
import RxCocoa
@testable import ProteGO

final class GcpClientMock: GcpClientType {

    var registerDeviceResult: Result<RegisterDeviceResponse, Error> = .failure(ErrorInfo("not initialized"))

    var confirmRegistrationResult: Result<ConfirmRegistrationResponse, Error> = .failure(ErrorInfo("not initialized"))

    var getStatusResult: Result<GetStatusResponse, Error> = .failure(ErrorInfo("not initialized"))

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResponse, Error>> {
        return .just(self.registerDeviceResult)
    }

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResponse, Error>> {
        return .just(self.confirmRegistrationResult)
    }

    func getStatus() -> Single<Result<GetStatusResponse, Error>> {
        return .just(self.getStatusResult)
    }
}
