import Foundation
import RealmSwift
import RxSwift

protocol RealmManagerType: class {
    var realm: Realm { get }
}
