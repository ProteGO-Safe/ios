//
//  RemoteConfigurationResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/05/2020.
//

import Foundation

struct RemoteConfigurationResponse: Decodable {
    let diagnosis: DiagnosisKeyDownloadConfiguration
    let exposure: ExposureConfiguration
    let subscription: SubscriptionConfiguration
}
