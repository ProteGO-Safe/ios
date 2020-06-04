//
//  WebCacheCleaner.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/06/2020.
//

import Foundation
import WebKit

final class WebCacheCleaner {
    
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        console("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                console("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
    
}
