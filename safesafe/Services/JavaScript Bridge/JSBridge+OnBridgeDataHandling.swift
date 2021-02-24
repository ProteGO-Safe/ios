//
//  JSBridge+OnBridgeDataHandling.swift
//  safesafe
//
//  Created by Namedix on 17/02/2021.
//

import UIKit
import PromiseKit
import StoreKit

extension JSBridge {

    /// Informing native about downloading new historical items (native will delete old data on his side).
    /// - Parameter jsonString: Json passed by PWA to work with native code.
    /// - JsonString example:
    /// ```
    ///{
    ///    "notifications": [ uuid4, uuid5 ],
    ///    "riskChecks": [ uuid1, uuid2 ],
    ///    "exposures": [ uuid12, uuid13 ]
    ///}
    /// ```
    func removeHistoricalData(jsonString: String?) {
        guard let request: DeleteHistoricalDataRequest = jsonString?.jsonDecode(decoder: jsonDecoder)
        else { return }

        historicalDataWorker?.clearData(request: request)
            .done { _ in
                console("Historical data removed")
            }
            .catch { console($0, type: .error) }
    }

    /// Call rate app alert.
    /// - Parameter jsonString: Json passed by PWA to work with native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     "appReview" : true
    /// }
    /// ```
    func requestAppreview(jsonString: String?) {
        guard let model: AppReviewResponse = jsonString?.jsonDecode(decoder: jsonDecoder), model.appReview
        else { return }

        #if STAGE_SCREENCAST || STAGE
        AppReviewMockAlertManager().show(type: .appReviewMock, result: {_ in })
        #else
        SKStoreReviewController.requestReview()
        #endif
    }

    /// Set application language.
    /// - Parameter jsonString: Json passed by PWA to work with native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     "language" : “EN”   //ISO 639-1
    /// }
    /// ```
    func changeLanguage(jsonString: String?) {
        guard let model: SystemLanguageResponse = jsonString?.jsonDecode(decoder: jsonDecoder)
        else { return }

        LanguageController.update(languageCode: model.language)
    }

    /// Unsubscribe from push notifications selected topic.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    ///   - dataType: The type by which we recognize what action the PWA application expects from the native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     ?????
    /// }
    /// ```
    func unsubscribeFromTopic(jsonString: String?, dataType: BridgeDataType) {
        guard let model: SurveyFinishedResponse = jsonString?.jsonDecode(decoder: jsonDecoder)
        else { return }

        NotificationManager.shared.unsubscribeFromDailyTopic(timestamp: model.timestamp)
    }

    /// Request about service permissions.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    ///   - dataType: The type by which we recognize what action the PWA application expects from the native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     "exposureNotificationStatus": 1
    ///     "isBtOn": true
    ///     "isNotificationEnabled": false
    /// }
    /// ```
    /// - exposureNotificationStatus:
    /// ```
    ///     1 - on
    ///     2 - off
    ///     3 - restricted
    /// ```
    func servicesPermissions(jsonString: String?, dataType: BridgeDataType) {
        isServicSetting = true
        guard let model: EnableServicesResponse = jsonString?.jsonDecode(decoder: jsonDecoder)
        else { return }

        // Manage Notifications
        if model.enableNotification == true {
            isServicSetting = false
            notificationsPermission(jsonString: jsonString, type: dataType)
            return
        }

        // Manage COVID ENA
        if let enableExposureNotification = model.enableExposureNotificationService {
            exposureNotificationBridge?.enableService(enable: enableExposureNotification)
                .done { [weak self] _ in
                    self?.sendAppStateJSON(type: .serviceStatus)
                    self?.isServicSetting = false
                }
                .catch(policy: .allErrors) { error in
                    console(error, type: .error)
                }
        }
    }

    /// Request about notification permission.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    ///   - dataType: The type by which we recognize what action the PWA application expects from the native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     "exposureNotificationStatus": 1
    ///     "isBtOn": true
    ///     "isNotificationEnabled": false
    /// }
    /// ```
    /// - exposureNotificationStatus:
    /// ```
    ///     1 - on
    ///     2 - off
    ///     3 - restricted
    /// ```
    func notificationsPermission(jsonString: String?, type: BridgeDataType) {
        Permissions.instance.state(for: .notifications)
            .then { state -> Promise<Permissions.State> in
                switch state {
                case .neverAsked:
                    return Permissions.instance.state(for: .notifications, shouldAsk: true)
                case .authorized:
                    return Promise.value(state)
                case .rejected:
                    guard let rootViewController = self.webView?.window?.rootViewController else {
                        throw InternalError.nilValue
                    }
                    return Permissions.instance.settingsAlert(for: .notifications, on: rootViewController)
                        .map { _ in Permissions.State.unknown }
                default:
                    return Promise.value(.unknown)
                }
            }
            .done { state in
                let didAuthorizeAPN = StoredDefaults.standard.get(key: .didAuthorizeAPN) ?? false
                if state == .authorized && !didAuthorizeAPN {
                    StoredDefaults.standard.set(value: true, key: .didAuthorizeAPN)

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }

                self.sendAppStateJSON(type: .serviceStatus)
                self.isServicSetting = false
            }
            .catch { error in
                Assertion.failure(error.localizedDescription)
            }
    }

    /// Notification about calculated exposure notification risk.
    /// - Parameter shouldDownload: Whether the method should download the data.
    func sendExposureList(shouldDownload: Bool = true) {
        exposureNotificationBridge?.getExposureSummary(shouldDownload: shouldDownload)
            .done { [weak self] summary in
                if let body = self?.encodeToJSON(summary) {
                    self?.onBridgeData(type: .exposureList, body: body) { _, error in
                        if let error = error {
                            console(error, type: .error)
                        }
                    }
                }
            }.catch {
                console($0, type: .error)
            }
    }

    /// Result of the historical data upload process.
    /// - Parameter jsonString: Json passed by PWA to work with native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     "result": 1
    /// }
    /// ```
    /// - result:
    /// ```
    ///     1 - success
    ///     2 - failure
    ///     3 - cancelled
    ///     4 - noInternet
    ///     5 - accessDenied
    /// ```
    func uploadTemporaryExposureKeys(jsonString: String?) {
        guard NetworkMonitoring.shared.isInternetAvailable else {
            NetworkingAlertManager().show(type: .noInternet) { [weak self] action in
                if case .retry = action {
                    self?.uploadTemporaryExposureKeys(jsonString: jsonString)
                } else if case .cancel = action {
                    self?.send(.canceled)
                }
            }
            return
        }

        guard let response: UploadTemporaryExposureKeysResponse = jsonString?.jsonDecode(decoder: jsonDecoder) else {
            send(.canceled)
            return
        }

        diagnosisKeysUploadService?.upload(usingResponse: response)
            .done {
                self.send(.success)
            }
            .catch { error in
                console(error)
                if let error = error as? InternalError {
                    switch error {
                    case .shareKeysUserCanceled:
                        self.send(.accessDenied)
                    default:
                        self.send(.canceled)
                    }
                } else {
                    self.send(.failure)
                }
            }
    }

    private func send(_ status: UploadTemporaryExposureKeysStatus) {
        guard let result = self.encodeToJSON(UploadTemporaryExposureKeysStatusResult(result: status))
        else { return }

        self.onBridgeData(type: .uploadTemporaryExposureKeys, body: result)
    }


    /// Lifecycle change notification.
    /// - Parameter type: The type by which we recognize what action the PWA application expects from the native code.
    func sendAppStateJSON(type: BridgeDataType) {
        serviceStatusManager.serviceStatusJson(delay: .zero)
            .done { json in
                console(json)
                self.onBridgeData(type: type, body: json)
            }
            .ensure {
                self.currentDataType = nil
            }
            .catch { error in
                console(error, type: .error)
            }
    }
}
