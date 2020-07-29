//
//  Fatal.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 14/07/2020.
//

import Foundation

final class Fatal {
    class func execute(_ message: String) -> Never {
        console(message)
        return abort()
    }
}
