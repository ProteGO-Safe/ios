import Foundation
import RxSwift
import Reachability

enum NetworkClientError: Error {
    case deallocated
    case networkUnavailable
    case failedToBuildUrlRequest(Error)
    case requestError(Error)
    case statusCode(Int, Data)
}

final class NetworkClient: ReactiveCompatible {

    fileprivate let session: URLSession

    fileprivate let urlRequestBuilder: UrlRequestBuilderType

    fileprivate let reachability: Reachability

    init(session: URLSession,
         urlRequestBuilder: UrlRequestBuilderType,
         reachability: Reachability) {
        self.session = session
        self.urlRequestBuilder = urlRequestBuilder
        self.reachability = reachability
    }
}

extension Reactive where Base: NetworkClient {

    func dataTask(networkRequest: NetworkRequest) -> Single<Result<Data, Error>> {
        guard base.reachability.connection != .unavailable else {
            return .just(.failure(NetworkClientError.networkUnavailable))
        }

        let urlRequest: URLRequest
        switch base.urlRequestBuilder.urlRequest(networkRequest: networkRequest) {
        case .success(let request):
            urlRequest = request
        case .failure(let error):
            return .just(.failure(NetworkClientError.failedToBuildUrlRequest(error)))
        }

        return Single<Result<Data, Error>>.create { [weak base] observer -> Disposable in
            guard let base = base else {
                observer(.success(.failure(NetworkClientError.deallocated)))
                return Disposables.create()
            }

            let session = base.session

            let task: URLSessionDataTask =
                session.dataTask(with: urlRequest, completionHandler: { [weak base] data, response, error in
                    guard let base = base else {
                        observer(.success(.failure(NetworkClientError.deallocated)))
                        return
                    }

                    let result = base.rx.handleRequestCompletion(data: data, response: response, error: error)
                    observer(.success(result))
            })

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    private func handleRequestCompletion(data: Data?, response: URLResponse?, error: Error?)
        -> Result<Data, Error> {
            if let error = error {
                return .failure(NetworkClientError.requestError(error))
            }

            guard let response = response as? HTTPURLResponse, let data = data else {
                return .failure(NetworkClientError.networkUnavailable)
            }

            guard 200...299 ~= response.statusCode else {
                return .failure(NetworkClientError.statusCode(response.statusCode, data))
            }

            return .success(data)
    }
}
