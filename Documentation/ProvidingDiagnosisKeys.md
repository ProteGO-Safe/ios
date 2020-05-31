# Providing Diagnosis Keys

Each new downloaded Diagnosis Key file (please see [Downloading Diagnosis Keys](DownloadingDiagnosisKeys.md) section) is provided for exposure checking. The check is performed by [Exposure Notification API](https://developer.apple.com/documentation/exposurenotification) with Exposure Configuration options that tune the matching algorithm. In order to provide elastic architecture, the exposure configuration is obtained from Firebase RemoteConfig service.
Periodic fetch of Diagnosis Keys is performed by [BackgroundTaskService](../safesafe/Services/ExposureNotification/BackgroundTasksService.swift) without need of user's interaction in the foreground.

Steps:
- New Diagnosis Key files that have never been analyzed are downloaded as described in [Downloading Diagnosis Keys](DownloadingDiagnosisKeys.md) section. Diagnosis Key files must be signed appropriately - the matching algorithm only runs on data that has been verified with the public key distributed by the device configuration mechanism. See more [here](https://static.googleusercontent.com/media/www.google.com/pt-BR//covid19/exposurenotifications/pdfs/Exposure-Key-File-Format-and-Verification.pdf).
- Exposure configuration options are obtained from Firebase RemoteConfig. The configuration allows to provide Health Authority recommendations regarding different aspects of exposure (like duration, attenuation or days since exposure). More about ExposureConfiguration can be found [here](https://developer.apple.com/documentation/exposurenotification/enexposureconfiguration).
  - Service function: [RemoteConfiguration.configuration()](../safesafe/Networking/RemoteConfig/RemoteConfig.swift)
- The new downloaded Diagnosis Key files and the Exposure Configuration are provided for [ENManager](https://developer.apple.com/documentation/exposurenotification/enmanager)
  - Service function: [ExposureService.detectExposures()](../safesafe/Services/ExposureNotification/ExposureService.swift)
- When the data has been successfully provided for [ENManager](https://developer.apple.com/documentation/exposurenotification/enmanager) then:
  - Information about the latest analyzed Diagnosis Key file timestamp is stored locally on a device (encrypted Shared Preferences). This information is used to select the future Diagnosis Key files that have not been analyzed yet – only files with higher Diagnosis Key timestamp are selected
    - Service function: [DiagnosisKeysDownloadService.download()](../safesafe/Services/ExposureNotification/DiagnosisKeysDownloadService.swift)
  - All sent to analysis Diagnosis Key files are deleted from device internal storage
    - Service function: [DiagnosisKeysDownloadService.deleteFiles()](../safesafe/Services/ExposureNotification/DiagnosisKeysDownloadService.swift)