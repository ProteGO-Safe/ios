//
//  Assertion.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 14/07/2020.
//

import Foundation

final class Assertion {
    class func failure(_ message: String) {
        console(message)
        #if !LIVE && !STAGE
        abort()
        #endif
    }
}
