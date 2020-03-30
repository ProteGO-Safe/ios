import Foundation

protocol UrlRequestBuilderType {

    func urlRequest(networkRequest: NetworkRequest) -> Result<URLRequest, Error>
}
