import Foundation

enum UrlRequestBuilderError: Error {
    case failedToCreateUrlComponents
    case failedToCreateUrl
}

final class UrlRequestBuilder: UrlRequestBuilderType {

    func urlRequest(networkRequest: NetworkRequest) -> Result<URLRequest, Error> {
        guard var urlComponents = URLComponents(string: networkRequest.url) else {
            return .failure(UrlRequestBuilderError.failedToCreateUrlComponents)
        }

        let queryItems = networkRequest.queryParameters?.map { (name, value) in
            return URLQueryItem(name: name, value: value)
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            return .failure(UrlRequestBuilderError.failedToCreateUrl)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkRequest.httpMethod.rawValue
        urlRequest.httpBody = networkRequest.body

        if let headers = networkRequest.headers {
            for (name, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: name)
            }
        }

        return .success(urlRequest)
    }
}
