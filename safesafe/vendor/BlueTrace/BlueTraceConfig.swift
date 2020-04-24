//
//  BluetraceConfig.swift
//  OpenTrace

import CoreBluetooth

import Foundation

struct BluetraceConfig {
    
    // To obtain the official BlueTrace Service ID and Characteristic ID, please email info@bluetrace.io
    static let BluetoothServiceID = CBUUID(string: ConfigManager.default.serviceUUID)
    
    // Staging and Prod uses the same CharacteristicServiceIDv2, since BluetoothServiceID is different
    static let CharacteristicServiceIDv2 = CBUUID(string: ConfigManager.default.v2CharacteristicId)
    static let charUUIDArray = [CharacteristicServiceIDv2]

    static let OrgID = ConfigManager.default.orgId
    static let ProtocolVersion = ConfigManager.default.protocolVersion

    static let CentralScanInterval = ConfigManager.default.centralScanInterval // in seconds
    static let CentralScanDuration = ConfigManager.default.centralScanDuration // in secondss

    static let TTLDays = ConfigManager.default.dataExpirationDays
}
