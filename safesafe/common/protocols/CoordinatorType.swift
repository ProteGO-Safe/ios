//
//  CoordinatorType.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

protocol CoordinatorType {
    init<T: CoordinatorType>(parent: T?)
    func start()
}

extension CoordinatorType {
    init<T: CoordinatorType>(parent: T? = nil) {
        self.init(parent: parent)
    }
}
