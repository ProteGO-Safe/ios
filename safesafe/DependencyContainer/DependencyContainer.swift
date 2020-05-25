//
//  DependencyContainer.swift
//  safesafe
//

import ExposureNotification
import Moya

final class DependencyContainer {
    
    @available(iOS 13.5, *)
    lazy var backgroundTaskService = BackgroundTasksService(exposureService: exposureService)
    
    lazy var deviceCheckService = DeviceCheckService()
    lazy var diagnosisKeysDownloadService = DiagnosisKeysDownloadService(with: remoteConfiguration)
    
    @available(iOS 13.5, *)
    lazy var diagnosisKeysUploadService = DiagnosisKeysUploadService(
        with: exposureService,
        deviceCheckService: deviceCheckService,
        exposureKeysProvider: MoyaProvider<ExposureKeysTarget>()
    )
    
    @available(iOS 13.5, *)
    lazy var exposureService = ExposureService(
        exposureManager: ENManager(),
        diagnosisKeysService: diagnosisKeysDownloadService,
        configurationService: remoteConfiguration,
        storageService: realmLocalStorage!
    )
    
    lazy var jsBridge = JSBridge(with: serviceStatusManager)
    lazy var realmLocalStorage = RealmLocalStorage()
    lazy var remoteConfiguration = RemoteConfiguration()
    lazy var serviceStatusManager = ServiceStatusManager(
        notificationManager: NotificationManager.shared
    )
    
}
