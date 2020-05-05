//
//  URLAction.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 20/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit.UIApplication

enum URLAction: String, CaseIterable {
    case tel
    case sms
    case mailto
    case facetime
    case facetimeAudio = "facetime-audio"
    
    func call(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
