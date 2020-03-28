import Foundation

enum UrlRequestBuilderError: Error {
    case failedToCreateUrlComponents
    case failedToCreateUrl
}

final class UrlRequestBuilder {

    func urlRequest(networkRequest: NetworkRequest) -> Result<URLRequest, UrlRequestBuilderError> {
        guard var urlComponents = URLComponents(string: networkRequest.url) else {
            return .failure(.failedToCreateUrlComponents)
        }

        let queryItems = networkRequest.queryParameters?.map { (name, value) in
            return URLQueryItem(name: name, value: value)
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            return .failure(.failedToCreateUrl)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkRequest.httpMethod.rawValue
        urlRequest.httpBody = networkRequest.body

        return .success(urlRequest)
    }
}
