//
//  BluetraceManager+CurrentState.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 23/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BluetraceManager {
    
    var currentState: CBManagerState {
        switch getCentralStateText() {
        case "poweredOff":
            return .poweredOff
        case "poweredOn":
            return .poweredOn
        case "resetting":
            return .resetting
        case "unauthorized":
            return .unauthorized
        case "unsupported":
            return .unsupported
        default:
            return .unknown
        }
    }
    
}
