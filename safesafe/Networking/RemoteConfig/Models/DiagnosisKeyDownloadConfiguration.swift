//
//  DiagnosisKeyDownloadConfiguration.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/05/2020.
//

import Foundation

struct DiagnosisKeyDownloadConfiguration: Decodable {
    let timeoutMobileSeconds: Int
    let timeoutWifiSeconds: Int
    let retryCount: Int
}
