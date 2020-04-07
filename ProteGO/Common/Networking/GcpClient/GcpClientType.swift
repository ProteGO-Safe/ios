import Foundation
import RxSwift

protocol GcpClientType {

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResponse, Error>>

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResponse, Error>>

    func getStatus(lastBeaconDate: Date?) -> Single<Result<GetStatusResponse, Error>>
}
