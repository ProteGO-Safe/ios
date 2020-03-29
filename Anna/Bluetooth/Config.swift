//
//  Config.swift
//  Anna
//
//  Created by Przemysław Lenart on 27/03/2020.
//  Copyright © 2020 GOV. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Anna Service contained in GATT
let AnnaServiceUUIDString = "89a60000-4f57-4c1b-9042-7ed87d723b4e"
let AnnaServiceUUID = CBUUID(string: AnnaServiceUUIDString)

/// Anna Characteristic contained in GATT
let AnnaCharacteristicUUIDString = "89a60001-4f57-4c1b-9042-7ed87d723b4e"
let AnnaCharacteristicUUID = CBUUID(string: AnnaCharacteristicUUIDString)


/// Time after which we check if connections health
let PeripheralSynchronizationCheckInSec: TimeInterval = 5

/// Synchronization timeout for a peripheral in seconds. Defines how long we should wait for established connection,
/// discovery and reading value before we decide to cancel our attempt.
let PeripheralSynchronizationTimeoutInSec: TimeInterval = 15

/// Peripheral ignored timeout in seconds. Defines how long we want to restrict connection attempts to this
/// device when synchronization was already completed.
let PeripheralIgnoredTimeoutInSec: TimeInterval = 60

/// Define how long we should wait before we attempt to reconnect to the device, which failed to synchronize.
let PeripheralReconnectionTimeoutPerAttemptInSec: TimeInterval = 5

/// Maxium number of concurrent connections established by a peripheral manager.
let PeripheralMaxConcurrentConnections = 3

/// Maximum number of connection retries before we decide to remove device until discovered once again.
let PeripheralMaxConnectionRetries = 3
