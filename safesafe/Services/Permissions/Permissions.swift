//
//  Permissions.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 26/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import CoreBluetooth
import PromiseKit

final class Permissions {
    
    static let instance = Permissions()
    
    private let bluetooth: PermissionType = BluetoothPermission()
    private let notifications: PermissionType = NotificationsPermission()
    
    enum Permission {
        case bluetooth
        case notifications
    }
    
    enum State {
        case neverAsked // unauthorized
        case rejected
        case authorized
        case cantUse // (restricted): This application is not authorized to use bluetooth. The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place.
        case unknown
    }
    
    enum AlertAction {
        case cancel
        case settings
    }
        
    private init() {}
    
    
    /// Get sevice authorization state
    /// - Parameters:
    ///   - permission: name of the service we want to ask for
    ///   - shouldAsk: if state is `neverAsked` and this flag is `true`, the authorization alert will be displayed for user. If flag is `false` only authorization state will be returned.
    /// Default value is `false`
    func state(for permission: Permission, shouldAsk: Bool = false) -> Promise<State> {
        switch permission {
        case .bluetooth:
            return bluetooth.state(shouldAsk: shouldAsk)
        case .notifications:
            return notifications.state(shouldAsk: shouldAsk)
        }
    }
    
    func settingsAlert(for permission: Permission, on viewController: UIViewController) -> Guarantee<AlertAction> {
        return Guarantee { fulfill in
            let (title, body) = self.alertCopy(for: permission)
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Anuluj", style: .cancel) { _ in
                fulfill(.cancel)
            }
            let settingsAction = UIAlertAction(title: "Ustawienia", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return fulfill(.settings)
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
                
                fulfill(.settings)
            }
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            
            DispatchQueue.main.async {
                viewController.present(alert, animated: true)
            }
        }
    }
    
    private func alertCopy(for permission: Permission) -> (title: String, body: String) {
        switch permission {
        case .bluetooth:
            return (title: "Włącz bluetooth", body: "Korzystając z modułu Bluetooth dbasz o siebie i bliskich. Włącz go w ustawieniach, żeby aplikacja mogła ostrzegać Cię o zagrożeniach.")
        case .notifications:
            return (title: "Włącz powiadomienia", body: "Do prawidłowego działania aplikacji potrzebna jest Twoja zgoda na wyświetlanie powiadomień. Włącz powiadomienia i pozwól ProteGO Safe wspierać ochronę zdrowia każdego z nas.")
        }
    }
}

