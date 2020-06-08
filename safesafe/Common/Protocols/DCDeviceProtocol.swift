//
//  DCDeviceProtocol.swift
//  safesafe

import DeviceCheck

protocol DCDeviceProtocol {
    
    var isSupported: Bool { get }
    func generateToken(completionHandler completion: @escaping (Data?, Error?) -> Void)
    
}

extension DCDevice: DCDeviceProtocol { }
