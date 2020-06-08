//
//  ExposureNotificationStatusProtocol.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 25/05/2020.
//

import Foundation
import PromiseKit

protocol ExposureNotificationStatusProtocol: class {
    var status: Promise<ServicesResponse.Status.ExposureNotificationStatus> { get }
    var isBluetoothOn: Promise<Bool> { get }
}
