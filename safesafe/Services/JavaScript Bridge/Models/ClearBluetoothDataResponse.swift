//
//  ClearBluetoothDataResponse.swift
//  safesafe
//

import Foundation

struct ClearBluetoothDataResponse: Codable {
    
    let clearBluetoothData: Bool
    
    private enum CodingKeys: String, CodingKey {
        case clearBluetoothData = "clearBtData"
    }
    
}
