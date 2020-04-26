//
//  PermissionType.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 26/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import PromiseKit

protocol PermissionType {
    func state(shouldAsk: Bool) -> Promise<Permissions.State>
}
