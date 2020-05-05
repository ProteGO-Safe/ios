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
    
    public static func log(_ value: Any?, type: LogType, file: String, function: String, line: Int, fullPath: Bool = false) {
        #if DEBUG
        var file = file
        if !fullPath {
            file = String(file.split(separator: "/").last ?? "")
        }
        print("\(type.prefix)[\(file):\(function):\(line)] \(String(describing: value))")
        #endif
    }
    
    /**
     Function from https://github.com/opentrace-community/opentrace-ios/blob/master/OpenTrace/Utils/Logger.swift
     
     Used in OpenTrace sources.
    */
    static func DLog(_ message: String, file: NSString = #file, line: Int = #line, functionName: String = #function) {
        #if DEBUG
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
        print("[\(formatter.string(from: Date()))][\(file.lastPathComponent):\(line)][\(functionName)]: \(message)")
        #endif
    }
    
}

