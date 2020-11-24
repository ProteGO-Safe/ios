//
//  DiagnosisKeysDownloadInfoModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 21/10/2020.
//

import RealmSwift
import Foundation

class DiagnosisKeysDownloadInfoModel: Object, LocalStorable {
    
    static let identifier: Int = 21102020
    
    @objc dynamic var id: Int = DiagnosisKeysDownloadInfoModel.identifier
    @objc dynamic var lastPackageTimestamp: Int = .zero
    
    override class func primaryKey() -> String? { "id" }
}
