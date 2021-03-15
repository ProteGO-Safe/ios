//
//  JSBridge+GetBridgeDataHandling.swift
//  safesafe
//
//  Created by Namedix on 17/02/2021.
//

import UIKit
import PromiseKit

extension JSBridge {

    /// Gets the status of services.
    /// - Parameter requestID: A unique key by which the PWA can recognize responses from the native application.
    func serviceStatusGetBridgeDataResponse(requestID: String) {
        serviceStatusManager.serviceStatusJson(delay: .zero)
            .done { [weak self] json in
                self?.bridgeDataResponse(type: .serviceStatus, body: json, requestId: requestID) { _ ,error in
                    if let error = error {
                        console(error, type: .error)
                    }
                }
            }.catch { error in
                console(error, type: .error)
            }
    }

    /// Gets the Exposure Notification Risk.
    /// - Parameter requestID: A unique key by which the PWA can recognize responses from the native application.
    func exposureListGetBridgeDataResponse(requestID: String) {
        exposureNotificationBridge?.getExposureSummary()
            .done { [weak self] summary in
                if let body = self?.encodeToJSON(summary) {
                    self?.bridgeDataResponse(type: .exposureList, body: body, requestId: requestID) { _, error in
                        if let error = error {
                            console(error, type: .error)
                        }
                    }
                }
            }.catch {
                console($0, type: .error)
            }
    }

    /// Gets the application version.
    /// - Parameter requestID: A unique key by which the PWA can recognize responses from the native application.
    func applicationVersionGetBridgeDataResponse(requestID: String) {
        guard let version = UIApplication.appVersion  else { return }
        let responseModel = ApplicationVersionResponse(appVersion: version)

        guard let responseData = encodeToJSON(responseModel) else { return }

        bridgeDataResponse(type: .appVersion, body: responseData, requestId: requestID)
    }

    /// Gets the selected system language.
    /// - Parameter requestID: A unique key by which the PWA can recognize responses from the native application.
    func systemLanguageGetBridgeDataResponse(requestID: String) {
        let responseModel = SystemLanguageResponse(language: LanguageController.selected.uppercased())

        guard let responseData = encodeToJSON(responseModel) else { return }

        bridgeDataResponse(type: .systemLanguage, body: responseData, requestId: requestID)
    }

    /// Download the state of all districts.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func districtsList(requestID: String, dataType: BridgeDataType) {
        console("💥 START districtsList")
        districtService?.hasDistricts()
            .then { districtsAvailable -> Promise<DistrictService.Response> in
                guard let service = self.districtService else { return .init(error: InternalError.deinitialized) }
                return service.perform(shouldFetchAPIData: !districtsAvailable)
            }.done { [weak self] response in
                guard let json = response.allDistrictsJSON else { return }
                console("💥 SENT districtsList")
                self?.bridgeDataResponse(type: dataType, body: json, requestId: requestID)
            }
            .catch { console($0, type: .error) }
    }

    /// Force the download of a list contains all districts from CDN.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func districsAPIFetch(requestID: String, dataType: BridgeDataType) {
        console("💥 START districsAPIFetch")
        districtService?.perform()
            .done { [weak self] response in
                guard let json = response.allDistrictsJSON else { return }
                console("💥 SENT districsAPIFetch")
                self?.bridgeDataResponse(type: dataType, body: json, requestId: requestID)
            }
            .catch { console($0, type: .error) }

    }

    /// Download the watch list of districts.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func subscribedDistricts(requestID: String, dataType: BridgeDataType) {
        districtService?.perform(shouldFetchAPIData: false)
            .done { [weak self] response in
                guard let json = response.observedJSON else { return }

                self?.bridgeDataResponse(type: dataType, body: json, requestId: requestID)
            }
            .catch { console($0, type: .error) }
    }

    /// Add/remove district from the watched ones.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    /// - JsonString example:
    /// ```
    /// {
    ///     "type": 1,
    ///     "districtId": 5
    /// }
    /// ```
    /// - Type:
    /// ```
    ///     1 - ADD
    ///     2 - DELETE
    /// ```
    func manageDistrictObserved(jsonString: String?, requestId: String, dataType: BridgeDataType) {
        guard let model: DistrictObservedManageModel = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }

        districtService?.manageObserved(model: model)
        districtService?.perform(shouldFetchAPIData: false)
            .done { [weak self] response in
                guard let json = response.observedJSON else { return }

                self?.bridgeDataResponse(type: dataType, body: json, requestId: requestId)
            }
            .catch { console($0, type: .error) }

        managePushNotificationAuthorization()
    }

    /// Submit the TEST PIN code.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    /// - JsonString example:
    /// ```
    /// {
    ///     "pin": 123FAB
    /// }
    /// ```
    func freeTestPinUpload(jsonString: String?, requestID: String, dataType: BridgeDataType) {
        guard let request: FreeTestUploadPinRequest = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }

        freeTestService?.uploadPIN(jsRequest: request)
            .done { [weak self] response in
                guard let jsonString = self?.encodeToJSON(response) else { return }

                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
            .catch { [weak self] error in
                guard let internalError = error as? InternalError else {
                    console(error, type: .error)
                    let response = FreeTestPinUploadResponse(result: .failed)
                    guard let jsonString = self?.encodeToJSON(response) else { return }
                    self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
                    return
                }

                var response: FreeTestPinUploadResponse?
                switch internalError {
                case .freeTestPinUploadFailed:
                    response = FreeTestPinUploadResponse(result: .failed)
                case .noInternet:
                    response = FreeTestPinUploadResponse(result: .canceled)
                default: ()
                }

                guard let strongResponse = response, let jsonString = self?.encodeToJSON(strongResponse)
                else { return }

                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
    }

    /// Gets subscription status.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    /// - JsonString example:
    /// ```
    /// {
    ///     "subscription":  {
    ///        "guid": "EAD80292-8AF1-4D6D-AD66-170CDDF8C432",
    ///        "status": 1,
    ///        "updated": 1614159202
    ///     }
    /// }
    /// ```
    /// - status:
    /// ```
    ///     0 - unverified
    ///     1 - verified
    ///     2 - signedForTest
    ///     3 - utilized
    ///     999 - unknown
    /// ```
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func freeTestSubscriptionInfo(jsonString: String?, requestID: String, dataType: BridgeDataType) {
        freeTestService?.subscriptionInfo()
            .done { [weak self] response in
                guard let jsonString = self?.encodeToJSON(response) else { return }

                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)

            }
            .catch { console($0, type: .error) }
    }

    /// Force the download PIN for test.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func freeTestPinCodeFetch(requestID: String, dataType: BridgeDataType) {
        freeTestService?.getPinCode()
            .done { [weak self] response in
                guard let jsonString = self?.encodeToJSON(response) else { return }

                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
            .catch {
                console($0, type: .error)
            }
    }

    /// Revocation of the risk of Exposure Notification. The user may cancel the risk in the application (e.g. by declaring that a test has been performed with a negative result).
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func clearExposureRisk(requestID: String, dataType: BridgeDataType) {
        exposureNotificationBridge?.clearExposureRisk()
            .done { [weak self] summary in
                if let body = self?.encodeToJSON(summary) {
                    self?.bridgeDataResponse(type: dataType, body: body, requestId: requestID)
                }
            }
            .catch { console($0, type: .error) }
    }

    /// Download notification list with pagination.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func historicalData(requestID: String, dataType: BridgeDataType) {
        historicalDataWorker?.getData()
            .done { [weak self] data in
                guard let jsonString = self?.encodeToJSON(data) else { return }

                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
            .catch { console($0, type: .error) }
    }

    /// Download COVID-19 statistics.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func dashboardStats(requestID: String, dataType: BridgeDataType) {
        dashboardWorker?.fetchData()
            .done { [weak self] jsonString in
                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
            .then(self.detailsWorker!.fetchData)
            .catch { console($0, type: .error) }
    }

    func detailsStats(requestID: String, dataType: BridgeDataType) {
        detailsWorker?.fetchData()
            .done { [weak self] jsonString in
                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
            .catch { console($0, type: .error) }
    }

    /// Gets notifications status.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func covidStatsSubscription(requestID: String, dataType: BridgeDataType) {
        let covidStatsSubscription = StoredDefaults.standard.get(key: .didUserSubscribeForCovidStatsTopic) ?? false

        guard let jsonString = CovidStatsResponse(isCovidStatsNotificationEnabled: covidStatsSubscription).jsonString
        else { return  }

        bridgeDataResponse(type: .covidStatsSubscription, body: jsonString, requestId: requestID)
    }

    /// Download aggregate Exposure Notification statistics.
    /// - Parameters:
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    func agregatedStats(requestID: String, dataType: BridgeDataType) {
        historicalDataWorker?.getAgregatedExposureData()
            .done { [weak self] model in
                guard let jsonString = ExposureHistoryRiskCheckAgregatedResponse(with: model).jsonString
                else { return }

                self?.bridgeDataResponse(type: dataType, body: jsonString, requestId: requestID)
            }
            .catch { console($0, type: .error) }
    }

    /// Change notifications status.
    /// - Parameters:
    ///   - jsonString: Json passed by PWA to work with native code.
    ///   - requestID: A unique key by which the PWA can recognize responses from the native application.
    ///   - dataType: The type by which the native app recognizes what action the PWA expects from it.
    /// - JsonString example:
    /// ```
    /// {
    ///     “isCovidStatsNotificationEnabled” = true/false
    /// }
    /// ```
    func setCovidStatsSubscription(jsonString: String?, requestID: String, dataType: BridgeDataType) {
        guard let request: CovidStatsRequest = jsonString?.jsonDecode(decoder: jsonDecoder) else { return }

        NotificationManager.shared.manageUserCovidStatsTopic(
            subscribe: request.isCovidStatsNotificationEnabled
        ) { [weak self] success in
            let currentState: Bool = StoredDefaults.standard.get(key: .didUserSubscribeForCovidStatsTopic)
                ?? StoredDefaults.standard.get(key: .didSubscribeForCovidStatsTopicByDefault)
                ?? false
            guard let jsonString = CovidStatsResponse(isCovidStatsNotificationEnabled: currentState).jsonString
            else { return }

            self?.bridgeDataResponse(type: .setCovidStatsSubscription, body: jsonString, requestId: requestID)
        }
    }
}
