import UIKit

protocol CustomView {

    associatedtype ViewClass

    var customView: ViewClass { get }
}

extension CustomView where Self: UIViewController {

    var customView: ViewClass {
        guard let customView = view as? ViewClass else {
            fatalError("Could not cast \(String(describing: view.self)) to type: \(ViewClass.self)")
        }

        return customView
    }
}
