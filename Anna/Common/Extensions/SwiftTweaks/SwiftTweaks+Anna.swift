import UIKit
import SwiftTweaks

extension Tweak {
    typealias Tweakable = TweakableType & Comparable

    static func build<T: Tweakable>(with description: DebugItemDescription,
                                    `default`: T,
                                    min: T? = nil,
                                    max: T? = nil,
                                    step: T? = nil) -> Tweak<T> {

        return Tweak<T>(description.collection.rawValue,
                        description.group.rawValue,
                        description.name,
                        defaultValue: `default`,
                        min: min,
                        max: max,
                        stepSize: step)
    }

    static func build<T>(with description: DebugItemDescription, `default`: T) -> Tweak<T> {

        return Tweak<T>(description.collection.rawValue,
                        description.group.rawValue,
                        description.name,
                        `default`)
    }
}

extension Tweak where T == TweakAction {
    static func build(with description: DebugItemDescription) -> Tweak<TweakAction> {

        return Tweak<TweakAction>(description.collection.rawValue,
                                  description.group.rawValue,
                                  description.name)
    }
}
