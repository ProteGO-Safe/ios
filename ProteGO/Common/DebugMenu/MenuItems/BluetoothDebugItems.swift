import Foundation
import UIKit
import SwiftTweaks

extension DebugMenu {

    public static var useMockBluetoothScanner: Tweak<Bool> = {
        let description = DebugItemDescription(.bluetooth, group: .testing, name: "Użyj mockowego skanowania BLE")
        return Tweak<Bool>.build(with: description, default: false)
    }()

    public static var useMockBluetoothAdvertiser: Tweak<Bool> = {
        let description = DebugItemDescription(.bluetooth, group: .testing, name: "Użyj mockowego rozgłaszania BLE")
        return Tweak<Bool>.build(with: description, default: false)
    }()

    public static var mockBluetoothAdvertiserInterval: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Adv Mock Interval")
        return Tweak<Int>.build(with: description, default: 30, min: 0)
    }()

    public static var mockBluetoothScannerInterval: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Scan Mock Interval")
        return Tweak<Int>.build(with: description, default: 60, min: 0)
    }()

    static var bluetoothItems: [TweakClusterType] = [
        useMockBluetoothScanner,
        useMockBluetoothAdvertiser,
        mockBluetoothAdvertiserInterval,
        mockBluetoothScannerInterval
    ]
}
