import Foundation
import RxSwift

protocol GcpClientType {

    func registerDevice(request: RegisterDeviceRequest) -> Single<Result<RegisterDeviceResult, Error>>

    func confirmRegistration(request: ConfirmRegistrationRequest) -> Single<Result<ConfirmRegistrationResult, Error>>
}
