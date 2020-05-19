//
//  AppLifeCycleResponse.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 19/05/2020.
//

import Foundation

struct ApplicationLifecycleResponse: Codable, JSONRepresentable {
    
    enum CodingKeys: String, CodingKey {
        case appicationState = "appState"
    }
    
    let appicationState: LifecycleSate
    
    enum LifecycleSate: Int, Codable {
        case willEnterForeground = 1
        case didEnterBackground = 2
    }
}

