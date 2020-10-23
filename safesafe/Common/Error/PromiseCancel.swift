//
//  PromiseCancel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 23/10/2020.
//

import PromiseKit

struct PromiseCancel: PromiseKit.CancellableError {
    let isCancelled: Bool = true
}
