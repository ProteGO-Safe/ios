import Foundation
import RxSwift

protocol GcpClientType {

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResult, Error>>

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResult, Error>>
}
