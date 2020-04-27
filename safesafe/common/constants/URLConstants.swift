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
    static let pwaURL = URL(string: "https://safesafe-dev.thecoders.io")!
    #elseif LIVE
    static let pwaURL = URL(string: "https://safesafe.app")!
    #endif
}

