//
//  SQLiteManager.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 07/10/2020.
//

import Foundation
import SQLite3

final class SQLiteManager {
    
    private var db:OpaquePointer?
    
    init() {
        db = openDatabase()
    }
    
    func openDatabase() -> OpaquePointer? {
        guard let dbDir = try? Directory.webkitLocalStorage() else { return nil }
        let dbURL = dbDir.appendingPathComponent("file__0.localstorage")
        var db: OpaquePointer? = nil
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK
        {
            console("error opening database", type: .error)
            return nil
        }
        else
        {
            console("Successfully opened connection to database at \(dbURL)")
            return db
        }
    }
    
    func read() -> String {
        var output = "NO_DATA"
        let queryStatementString = "SELECT * FROM ItemTable;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let key = String(cString: sqlite3_column_text(queryStatement, 0))
                let valueLen = sqlite3_column_bytes(queryStatement, 1)
                let valuePoint = sqlite3_column_blob(queryStatement, 1)
                guard let bytes = valuePoint else {
                    console("Can't read SQLite bytes")
                    return output
                }
            
                let data = Data(bytes: bytes, count: Int(valueLen))
                let valueStr = String(bytes: data, encoding: .utf16LittleEndian) ?? "NO_VALUE"
                let jsonData = valueStr.data(using: .utf8)!
                do {
                    guard let dict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else { return output }
                    output = ""
                    
                    output.append("> SQLITE KEY: \(key)\n")
                    for (key, value) in dict {
                        output.append("\(key.replacingOccurrences(of: "\\", with: "")): \(value)\n")
                    }
                    
                    return output
                    
                } catch { console(error, type: .error) }
            }
        } else {
            console("SELECT statement could not be prepared", type: .error)
        }
        sqlite3_finalize(queryStatement)
        
        return output
    }
}
