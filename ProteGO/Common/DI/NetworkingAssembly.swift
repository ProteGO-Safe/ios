import Swinject
import Reachability

final class NetworkingAssembly: Assembly {

    func assemble(container: Container) {
        registerReachability(container)
        registerUrlRequestBuilder(container)
        registerNetworkClient(container)
        registerRequestBuilder(container)
        registerGcpClient(container)
    }

    private func registerReachability(_ container: Container) {
        container.register(Reachability.self) { _ in
            guard let reachability = try? Reachability() else {
                logger.error("Fatal error: failed to initialize Reachability")
                fatalError()
            }
            return reachability
        }.inObjectScope(.container)
    }

    private func registerUrlRequestBuilder(_ container: Container) {
        container.register(UrlRequestBuilderType.self) { _ in
            return UrlRequestBuilder()
        }
    }

    private func registerNetworkClient(_ container: Container) {
        container.register(NetworkClient.self) { resolver in
            return NetworkClient(
                session: URLSession(configuration: URLSessionConfiguration.default),
                urlRequestBuilder: resolver.resolve(UrlRequestBuilderType.self),
                reachability: resolver.resolve(Reachability.self))
        }
    }

    private func registerRequestBuilder(_ container: Container) {
        container.register(RequestBuilderType.self) { resolver in
            return RequestBuilder(registrationManager: resolver.resolve(RegistrationManagerType.self))
        }
    }

    private func registerGcpClient(_ container: Container) {
        container.register(GcpClientType.self) { resolver in
            return GcpClient(
                networkClient: resolver.resolve(NetworkClient.self),
                requestBuilder: resolver.resolve(RequestBuilderType.self),
                registrationManager: resolver.resolve(RegistrationManagerType.self)
             )
        }
    }
}
