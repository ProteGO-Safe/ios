//
//  AlamofireSessionManagerBuilder.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/06/2020.
//

import Foundation
import Moya
import Alamofire
import Security
import TrustKit

class CustomSessionDelegate: SessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler)
    }
    
}
