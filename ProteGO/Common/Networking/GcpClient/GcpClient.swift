import Foundation
import RxSwift
import RxCocoa

enum GcpClientError: Error {
    case failedToDecodeResponseData(Error)
    case failedToBuildRequest
}

final class GcpClient: GcpClientType {

    private let networkClient: NetworkClient

    private let requestBuilder: RequestBuilderType

    private let registrationManager: RegistrationManagerType

    init(networkClient: NetworkClient,
         requestBuilder: RequestBuilderType,
         registrationManager: RegistrationManagerType) {
        self.networkClient = networkClient
        self.requestBuilder = requestBuilder
        self.registrationManager = registrationManager
    }

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResult, Error>> {
        let request = requestBuilder.registerDeviceRequest(msisdn: msisdn)

        let endpoint = GcpEndpoint.registerDevice(request)
        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map({ result -> Result<RegisterDeviceResult, Error> in
                return result.flatMap { data in
                    do {
                        let decoded = try JSONDecoder().decode(RegisterDeviceResult.self, from: data)
                        return .success(decoded)
                    } catch {
                        return .failure(GcpClientError.failedToDecodeResponseData(error))
                    }
                }
            }).do(onSuccess: { [weak self] result in
                switch result {
                case .success(let result):
                    logger.debug("Did send registration code")
                    self?.registrationManager.register(registrationId: result.registrationId)
                    if DebugMenu.assign(DebugMenu.registrationDebugNoSms) {
                        self?.registrationManager.set(debugRegistrationCode: result.debugCode)
                    }

                case .failure(let error):
                    logger.error("Failed to send registration code: \(error)")
                }
            })
    }

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResult, Error>> {
        guard let request = requestBuilder.confirmRegistrationRequest(code: code) else {
            return .just(.failure(GcpClientError.failedToBuildRequest))
        }

        let endpoint = GcpEndpoint.confirmRegistration(request)

        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map({ result -> Result<ConfirmRegistrationResult, Error> in
                return result.flatMap { data in
                    do {
                        let decoded = try JSONDecoder().decode(ConfirmRegistrationResult.self, from: data)
                        return .success(decoded)
                    } catch {
                        return .failure(GcpClientError.failedToDecodeResponseData(error))
                    }
                }
            }).do(onSuccess: { [weak self] result in
                switch result {
                case .success(let result):
                    logger.debug("Did verify registration code")
                    self?.registrationManager.confirmRegistration(userId: result.userId)
                case .failure(let error):
                    logger.error("Failed to verify registration code: \(error)")
                }
            })
    }
}
