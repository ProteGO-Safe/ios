//
//  Result+Void.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import PromiseKit

extension Swift.Result where Success == Void {
    static var success: Swift.Result<Void, Failure> {
        return .success(())
    }
}


extension Swift.Result {
    func toPromise() -> Promise<Success> {
        Promise { seal in
            switch  self {
            case .success(let success):
                seal.fulfill(success)
            case .failure(let error):
                seal.reject(error)
            }
        }
    }
}
