//
//  WebCacheCleaner.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 04/06/2020.
//

import Foundation
import WebKit
import PromiseKit

final class WebCacheCleaner {
    
    @discardableResult
    class func clean() -> Promise<Void> {
        return Promise { seal in
            let dispatchGroup = DispatchGroup()
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    dispatchGroup.enter()
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: { dispatchGroup.leave() })
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                seal.fulfill(())
            }
        }
    }
    
    class func removeLocalStorage() {
        do {
            let dir = try Directory.webkitLocalStorage()
            let content = try FileManager.default.contentsOfDirectory(atPath: dir.path)
            for path in content {
                let fullPath = dir.appendingPathComponent(path)
                try FileManager.default.removeItem(at: fullPath)
            }
        } catch { console(error) }
    }
}
