import Foundation
import RxSwift
import RxCocoa

enum GcpClientError: Error {
    case failedToDecodeResponseData(Error)
}

final class GcpClient: GcpClientType {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func registerDevice(request: RegisterDeviceRequest) -> Single<Result<RegisterDeviceResult, Error>> {
        let endpoint = GcpEndpoint.registerDevice(request)
        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map { result -> Result<RegisterDeviceResult, Error> in
                return result.flatMap { data in
                    do {
                        let decoded = try JSONDecoder().decode(RegisterDeviceResult.self, from: data)
                        return .success(decoded)
                    } catch {
                        return .failure(GcpClientError.failedToDecodeResponseData(error))
                    }
                }
        }
    }

    func confirmRegistration(request: ConfirmRegistrationRequest) -> Single<Result<ConfirmRegistrationResult, Error>> {
        let endpoint = GcpEndpoint.confirmRegistration(request)
        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map { result -> Result<ConfirmRegistrationResult, Error> in
                return result.flatMap { data in
                    do {
                        let decoded = try JSONDecoder().decode(ConfirmRegistrationResult.self, from: data)
                        return .success(decoded)
                    } catch {
                        return .failure(GcpClientError.failedToDecodeResponseData(error))
                    }
                }
        }
    }
}
