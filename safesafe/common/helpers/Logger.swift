//
//  Logger.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 16/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

public final class Logger {
    public static func log(_ value: String, file: String, function: String, line: Int, fullPath: Bool = false) {
        #if DEBUG
        var file = file
        if !fullPath {
            file = String(file.split(separator: "/").last ?? "")
        }
        print("Logger[\(file):\(function):\(line)] \(value)")
        #endif
    }
}

