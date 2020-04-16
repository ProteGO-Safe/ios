//
//  Logger.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 16/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

public final class Logger {
    
    public enum LogType {
        case regular
        case warning
        case error
        
        var prefix: String {
            switch self {
            case .regular:
                return "Debug"
            case .warning:
                return "⚠️ Warning"
            case .error:
                return "⛔️ Error"
            }
        }
    }
    
    public static func log(_ value: Any, type: LogType, file: String, function: String, line: Int, fullPath: Bool = false) {
        #if DEBUG
        var file = file
        if !fullPath {
            file = String(file.split(separator: "/").last ?? "")
        }
        print("\(type.prefix)[\(file):\(function):\(line)] \(String(describing: value))")
        #endif
    }
}

