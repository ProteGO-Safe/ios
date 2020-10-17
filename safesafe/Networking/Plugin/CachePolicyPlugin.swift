//
//  CachePolicyPlugin.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 07/10/2020.
//

import Moya

final class CachePolicyPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutableRequest = request
        mutableRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return mutableRequest
    }
}
