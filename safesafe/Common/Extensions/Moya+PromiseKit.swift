//
//  Moya+PromiseKit.swift
//  safesafe
//
//  Created by Namedix on 22/02/2021.
//

import Moya
import PromiseKit

extension MoyaProvider {
    func request(
        _ target: Target,
        callbackQueue: DispatchQueue? = .none,
        progress: ProgressBlock? = .none
    ) -> Promise<Moya.Response> {
        Promise { seal in
            request(
                target,
                callbackQueue: callbackQueue,
                progress: progress
            ) { result in
                switch result {
                case .success(let response):
                    seal.fulfill(response)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
