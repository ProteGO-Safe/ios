//
//  BluetraceConfig.swift
//  OpenTrace

import CoreBluetooth

/**
 File from https://github.com/opentrace-community/opentrace-ios/blob/master/OpenTrace/Bluetrace/BluetraceConfig.swift
 
 Used in OpenTrace sources.
*/
struct BluetraceConfig {
    
    #if DEV
    static let BluetoothServiceID = CBUUID(string: "A6BA4286-C550-4794-A888-9467EF0B31A8")
    static let CharacteristicServiceIDv2 = CBUUID(string: "D1034710-B11E-42F2-BCA3-F481177D5BB2")
    #elseif STAGE
    static let BluetoothServiceID = CBUUID(string: "60B772DC-5417-4760-AC10-3E30074C4833")
    static let CharacteristicServiceIDv2 = CBUUID(string: "8FBFDF09-5EB4-4F68-AC16-6CD2275D07CA")
    #elseif LIVE
    static let BluetoothServiceID = CBUUID(string: "6E9E7830-F4C7-4717-B0D8-525D30181121")
    static let CharacteristicServiceIDv2 = CBUUID(string: "8FBFDF09-5EB4-4F68-AC16-6CD2275D07CA")
    #endif

    static let charUUIDArray = [CharacteristicServiceIDv2]

    static let OrgID = "OT_PL" // TODO: Update with official org ID
    static let ProtocolVersion = 2

    static let CentralScanInterval = 60 // in seconds
    static let CentralScanDuration = 10 // in seconds

    static let TTLDays = -21
    
}
