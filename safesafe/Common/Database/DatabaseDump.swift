//
//  DataBaseDump.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 30/04/2020.
//

import UIKit
import CoreData

final class DatabaseDump {

    private var fileName: String {
        let manufacturer = "Apple"
        let model = DeviceInfo.getModel().replacingOccurrences(of: " ", with: "")

        let date: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let todayDate = dateFormatter.string(from: date)

        return  "StreetPassRecord_\(manufacturer)_\(model)_\(todayDate).json"
    }
    
    private struct UploadFileData: Encodable {

        var token: String
        var records: [Encounter]
        var events: [Encounter]

    }
    
    func toJSON(token: String, result: @escaping (Result<URL, Error>) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            result(.failure(InternalError.nilValue))
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let recordsFetchRequest: NSFetchRequest<Encounter> = Encounter.fetchRequestForRecords()
        let eventsFetchRequest: NSFetchRequest<Encounter> = Encounter.fetchRequestForEvents()

        managedContext.perform { [unowned self] in
            guard let records = try? recordsFetchRequest.execute() else {
                Logger.DLog("Error fetching records")
                return result(.failure(InternalError.databaseFetchingRecords))
            }

            guard let events = try? eventsFetchRequest.execute() else {
                Logger.DLog("Error fetching events")
                return result(.failure(InternalError.databaseFetchingEvents))
            }

            let data = UploadFileData(token: token, records: records, events: events)

            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(data) else {
                Logger.DLog("Error serializing data")
                return result(.failure(InternalError.jsonSerializingData))
            }

            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                Logger.DLog("Error locating user documents directory")
                return result(.failure(InternalError.locatingDictionary))
            }

            let fileURL = directory.appendingPathComponent(self.fileName)
            
            do {
                try json.write(to: fileURL, options: [])
                result(.success(fileURL))
            } catch {
                Logger.DLog("Error writing to file")
                return result(.failure(InternalError.writingToFile))
            }
            
        }
    }
}

