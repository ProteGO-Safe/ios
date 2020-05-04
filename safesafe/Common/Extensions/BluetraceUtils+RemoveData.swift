//
//  BluetraceUtils+RemoveData.swift
//  safesafe
//

import UIKit
import CoreData

extension BluetraceUtils {
    
    static func removeAllData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Encounter.fetchRequest())

        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            console(error)
        }
    }
    
}
