//
//  URLs.swift
//  safesafe Live
//
//  Created by Lukasz szyszkowski on 16/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

enum URLContants {
    #if DEV
    static let pwaHost = "safesafe-dev.thecoders.io"
    static let pwaScheme = "https"
    #elseif LIVE
    static let pwaHost = "safesafe.app"
    static let pwaScheme = "https"
    #endif
    
    static var pwaURL: URL = .build(scheme: URLContants.pwaScheme, host: URLContants.pwaHost)!
}
