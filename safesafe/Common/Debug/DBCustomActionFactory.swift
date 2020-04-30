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

final class DBCustomActionFactory {

    private static let dbDump = DatabaseDump()
    
    static func makeBluetraceDBDumpAction(window: UIWindow) -> DBCustomAction {
        return DBCustomAction(name: "Blue Trace JSON") {
            dbDump.toJSON(token: "SOME_UPLOAD_TOKEN") { result in
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
