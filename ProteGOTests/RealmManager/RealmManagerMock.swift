import Foundation
import RealmSwift
@testable import ProteGO

final class RealmManagerMock: RealmManagerType {
    var realm: Realm {
        // swiftlint:disable:next force_try
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: realmId))
    }

    var realmId = UUID().uuidString
}
