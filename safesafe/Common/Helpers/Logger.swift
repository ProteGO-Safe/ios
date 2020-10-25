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
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss.SSS"
        
        return formatter
    }()
    
    public static func log(_ value: Any?, type: LogType, file: String, function: String, line: Int, fullPath: Bool = false) {
        #if !LIVE
        let formattedMessage = logFormat(value, type: type, file: file, function: function, line: line, fullPath: fullPath)
        print(formattedMessage)
        Self.fileLog(formattedMessage)
        #endif
    }
    
    private static func logFormat(_ value: Any?, type: LogType, file: String, function: String, line: Int, fullPath: Bool = false) -> String {
        var file = file
        if !fullPath {
            file = String(file.split(separator: "/").last ?? "")
        }
        
        return "\(type.prefix)[\(file):\(function):\(line)] \(String(describing: value))"
    }
    
    private static func fileLog(_ message: String) {
        if #available(iOS 13.5, *) {
            DispatchQueue.global(qos: .background).async {
                let datePrefix = "{\(Logger.dateFormatter.string(from: Date()))}"
                let line = "\(datePrefix) \(message)"
                File.logToFile(line)
            }
        }
    }
}

