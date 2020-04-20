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
    static let pwaURL = URL(string: "DEV_WEB_URL")!
    #elseif LIVE
    static let pwaURL = URL(string: "PROD_DEV_URL")!
    #endif
}

