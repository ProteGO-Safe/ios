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

    public static var bluetoothScannerOnTime: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Scan ON time (bg)")
        return Tweak<Int>.build(with: description, default: Int(Constants.Bluetooth.ScanningOnTimeout), min: 10)
    }()

    public static var bluetoothScannerOffTime: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Scan OFF time (bg)")
        return Tweak<Int>.build(with: description, default: Int(Constants.Bluetooth.ScanningOffTimeout), min: 10)
    }()

    public static var bluetoothAdvertiserOnTime: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Adv. ON time (bg)")
        return Tweak<Int>.build(with: description, default: Int(Constants.Bluetooth.AdvertisingOnTimeout), min: 10)
    }()

    public static var bluetoothAdvertiserOffTime: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Adv OFF time (bg)")
        return Tweak<Int>.build(with: description, default: Int(Constants.Bluetooth.AdvertisingOffTimeout), min: 10)
    }()

    public static var bluetoothMaxConcurrentConnections: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Max conn.")
        return Tweak<Int>.build(
            with: description,
            default: Int(Constants.Bluetooth.PeripheralMaxConcurrentConnections), min: 1, max: 8)
    }()

    public static var bluetoothMaxConnectionRetries: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Max retries")
        return Tweak<Int>.build(
            with: description,
            default: Int(Constants.Bluetooth.PeripheralMaxConnectionRetries), min: 1, max: 8)
    }()

    public static var bluetoothDeviceIgnoredTimeout: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Next sync")
        return Tweak<Int>.build(
            with: description,
            default: Int(Constants.Bluetooth.PeripheralIgnoredTimeoutInSec), min: 10)
    }()

    public static var bluetoothSynchronizationTimeout: Tweak<Int> = {
        let description = DebugItemDescription(.bluetooth, group: .testing,
                                               name: "Sync timeout")
        return Tweak<Int>.build(
            with: description,
            default: Int(Constants.Bluetooth.PeripheralSynchronizationTimeoutInSec), min: 10)
    }()

    static var actionShowBeaconIdsDebugScreen: Tweak<TweakAction> = {
          let description = DebugItemDescription(.bluetooth, group: .testing, name: "Pokaż identyfikatory BLE")
          let tweak = Tweak<TweakAction>.build(with: description)
          tweak.addClosure {
              guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                  return
              }

              guard let rootViewController = appDelegate.window?.rootViewController else {
                  return
              }

              let debugViewController: RegisteredBeaconIdsDebugViewController =
                  appDelegate.resolver.resolve(RegisteredBeaconIdsDebugViewController.self)

              if let presentedViewController = rootViewController.presentedViewController {
                  presentedViewController.dismiss(animated: true) {
                      rootViewController.present(debugViewController, animated: true)
                  }
              } else {
                  rootViewController.present(debugViewController, animated: true)
              }

          }
          return tweak
      }()

    static var bluetoothItems: [TweakClusterType] = [
        useMockBluetoothScanner,
        useMockBluetoothAdvertiser,
        mockBluetoothAdvertiserInterval,
        mockBluetoothScannerInterval,
        bluetoothScannerOnTime,
        bluetoothScannerOffTime,
        bluetoothAdvertiserOnTime,
        bluetoothAdvertiserOffTime,
        bluetoothMaxConcurrentConnections,
        bluetoothMaxConnectionRetries,
        bluetoothDeviceIgnoredTimeout,
        bluetoothSynchronizationTimeout,
        actionShowBeaconIdsDebugScreen
    ]
}
