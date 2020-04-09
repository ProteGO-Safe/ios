import Foundation
import RxSwift
import RxCocoa

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

    func registerDevice(msisdn: String) -> Single<Result<RegisterDeviceResponse, Error>> {
        let request = requestBuilder.registerDeviceRequest(msisdn: msisdn)

        let endpoint = GcpEndpoint.registerDevice(request)
        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map({ result -> Result<RegisterDeviceResponse, Error> in
                return result.flatMap { data in
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decoded = try decoder.decode(RegisterDeviceResponse.self, from: data)
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
                    logger.error("Failed to send registration code: \(error.localizedDescription)")
                }
            })
    }

    func confirmRegistration(code: String) -> Single<Result<ConfirmRegistrationResponse, Error>> {
        guard let request = requestBuilder.confirmRegistrationRequest(code: code) else {
            return .just(.failure(GcpClientError.failedToBuildRequest))
        }

        let endpoint = GcpEndpoint.confirmRegistration(request)

        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map({ result -> Result<ConfirmRegistrationResponse, Error> in
                return result.flatMap { data in
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decoded = try decoder.decode(ConfirmRegistrationResponse.self, from: data)
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
                    logger.error("Failed to verify registration code: \(error.localizedDescription)")
                }
            })
    }

    func registerNoMsisdn() -> Single<Result<RegisterNoMsisdnResponse, Error>> {
        let request = requestBuilder.registerNoMsisdnRequest()

        let endpoint = GcpEndpoint.registerNoMsisdn(request)
        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map({ result -> Result<RegisterNoMsisdnResponse, Error> in
                return result.flatMap { data in
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decoded = try decoder.decode(RegisterNoMsisdnResponse.self, from: data)
                        return .success(decoded)
                    } catch {
                        return .failure(GcpClientError.failedToDecodeResponseData(error))
                    }
                }
            }).do(onSuccess: { [weak self] result in
                switch result {
                case .success(let result):
                    logger.debug("Did register without phone number")
                    self?.registrationManager.confirmRegistration(userId: result.userId)
                case .failure(let error):
                    logger.error("Failed to register without phone number: \(error.localizedDescription)")
                }
            })
    }

    func getStatus(lastBeaconDate: Date?) -> Single<Result<GetStatusResponse, Error>> {
        guard let request = requestBuilder.getStatusRequest(lastBeaconDate: lastBeaconDate) else {
            return .just(.failure(GcpClientError.failedToBuildRequest))
        }

        let endpoint = GcpEndpoint.getStatus(request)

        return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
            .map({ result -> Result<GetStatusResponse, Error> in
                return result.flatMap { data in
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMddHH)
                        decoder.keyDecodingStrategy = .convertFromSnakeCase

                        let decoded = try decoder.decode(GetStatusResponse.self, from: data)
                        return .success(decoded)
                    } catch {
                        return .failure(GcpClientError.failedToDecodeResponseData(error))
                    }
                }
            }).do(onSuccess: { result in
                switch result {
                case .success:
                    logger.debug("Did recieved status")
                case .failure(let error):
                    logger.error("Failed to recieved status: \(error.localizedDescription)")
                }
            })
    }

    func sendHistory(confirmCode: String, encounters: [Encounter]) -> Single<Result<SendHistoryResponse, Error>> {
           guard let request = requestBuilder.sendHistoryRequest(confirmCode: confirmCode, encounters: encounters) else {
               return .just(.failure(GcpClientError.failedToBuildRequest))
           }

           let endpoint = GcpEndpoint.sendHistory(request)

           return networkClient.rx.dataTask(networkRequest: endpoint.networkRequest)
               .map({ result -> Result<SendHistoryResponse, Error> in
                   return result.flatMap { data in
                       do {
                           let decoder = JSONDecoder()
                           decoder.keyDecodingStrategy = .convertFromSnakeCase

                           let decoded = try decoder.decode(SendHistoryResponse.self, from: data)
                           return .success(decoded)
                       } catch {
                           return .failure(GcpClientError.failedToDecodeResponseData(error))
                       }
                   }
               }).do(onSuccess: { result in
                   switch result {
                   case .success:
                       logger.debug("Successfully send history")
                   case .failure(let error):
                    logger.error("Failed to send history: \(error.localizedDescription)")
                   }
               })
       }
}
