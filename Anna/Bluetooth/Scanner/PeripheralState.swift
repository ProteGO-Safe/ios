//
//  PeripheralState.swift
//  Anna
//
//  Created by Przemysław Lenart on 28/03/2020.
//  Copyright © 2020 GOV. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralState {
    case Idle
    case Connecting
    case Connected
    case DiscoveringService
    case DiscoveredService(CBService)
    case DiscoveringCharacteristic
    case DiscoveredCharacteristic(CBCharacteristic)
    case ReadingCharacteristic

    func isIdle() -> Bool {
        if case .Idle = self {
            return true
        }
        return false
    }
}
