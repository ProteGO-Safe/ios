//
//  DependencyContainer.swift
//  safesafe
//

import ExposureNotification
import Moya
import FirebaseRemoteConfig

final class DependencyContainer {
    
    @available(iOS 13.5, *)
    lazy var backgroundTaskService = BackgroundTasksService(exposureService: exposureService)
    
    lazy var deviceCheckService = DeviceCheckService()
    
    @available(iOS 13.5, *)
    lazy var diagnosisKeysDownloadService = DiagnosisKeysDownloadService(
        with: remoteConfiguration,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>()
    )
    
    @available(iOS 13.5, *)
    lazy var diagnosisKeysUploadService = DiagnosisKeysUploadService(
        with: exposureService,
        deviceCheckService: deviceCheckService,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>(session: CustomSession.defaultSession())
    )
    
    @available(iOS 13.5, *)
    lazy var exposureService = ExposureService(
        exposureManager: ENManager(),
        diagnosisKeysService: diagnosisKeysDownloadService,
        configurationService: remoteConfiguration,
        storageService: realmLocalStorage
    )
    
    @available(iOS 13.5, *)
    lazy var exposureSummaryService: ExposureSummaryServiceProtocol = ExposureSummaryService(
        storageService: realmLocalStorage
    )
    
    lazy var jailbreakService: JailbreakServiceProtocol = JailbreakService()
    lazy var jsBridge = JSBridge(with: serviceStatusManager)
    lazy var realmLocalStorage = RealmLocalStorage()
    lazy var remoteConfigSetting: RemoteConfigSettings = {
        let settings = RemoteConfigSettings()
        settings.fetchTimeout = 10
        return settings
    }()
    lazy var remoteConfiguration = RemoteConfiguration(settings: remoteConfigSetting)
    
    lazy var serviceStatusManager: ServiceStatusManagerProtocol = {
        if #available(iOS 13.5, *) {
            return ServiceStatusManager(
                notificationManager: NotificationManager.shared,
                exposureNotificationStatus: exposureService
            )
        } else {
            return ServiceStatusManager(
                notificationManager: NotificationManager.shared,
                exposureNotificationStatus: ExposureNotificationStatusMock()
            )
        }
    }()
    
}
