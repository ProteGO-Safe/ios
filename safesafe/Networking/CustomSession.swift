//
//  CustomSession.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/06/2020.
//

import Foundation
import Alamofire
import Moya

class CustomSession {
    final class func defaultSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        return Session(configuration: configuration, delegate: CustomSessionDelegate(), startRequestsImmediately: false)
    }
}
