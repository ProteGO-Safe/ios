//
//  CustomActions.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/04/2020.
//

import UIKit

#if !LIVE
    import DBDebugToolkit
#endif
final class CustomActions {

    private static let dbDump = DatabaseDump()
    
    static func bluetraceDBDumpAction(window: UIWindow) -> DBCustomAction {
        return DBCustomAction(name: "Blue Trace JSON") {
            dbDump.toJSON { result in
                do {
                    let url = try result.get()
                    DispatchQueue.main.async {
                        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        window.rootViewController?.presentedViewController?.present(activityController, animated: true, completion: nil)
                    }
                } catch {
                    Logger.DLog(error.localizedDescription)
                }
            }
        }
    }
}
