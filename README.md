# ProteGO Safe iOS App

![Logo](./ghImages/logo.png "ProteGO Safe")

## Project overview

This is an iOS application for [ProteGO Safe project](https://github.com/ProteGO-Safe/specs) and it implements two main features:
* User daily triage
* Contact tracing - module that is fully based on [Exposure Notification API](https://developer.apple.com/documentation/exposurenotification) provided by Google and Apple and it's goal is to inform people of potential exposure to COVID-19.

Application is structured based MVVM-C pattern, where presentation (UI) layer is almost fully realized with a single UIViewController with a WKWebView that loads a website application called 'PWA' (Progressive Web App). PWA is responsible for GUI, user interaction and 'User daily triage' feature. Website app interacts with native code through the JavaScript bridge.

App implements contact tracing module that is based on [Exposure Notification API](https://developer.apple.com/documentation/exposurenotification) (EN) and we can extract couple of features related to this:
* [Controlling EN](Documentation/ControllingExposureNotification.md): enable/disable, check if device supports it, check what is its state
* [Uploading Temporary Exposure Keys](Documentation/UploadingTemporaryExposureKeys.md) (TEKs) of positively diagnosed user verified by the application: authorize user for TEKs upload, get TEKs from EN, add proper verification data (using [DeviceCheck Framework](https://developer.apple.com/documentation/devicecheck)), upload data to the Cloud Server.
* [Downloading](Documentation/DownloadingDiagnosisKeys.md) periodically files with batch of TEKs of positively diagnosed users (that recently uploaded their TEKs): execute periodic task responsible for downloading recently created .zip files (it fetches list of available files from CDN, selects only not yet analyzed files and downloads only these ones)
* [Providing files](Documentation/ProvidingDiagnosisKeys.md) to EN API for detecting exposures: get proper configuration for risk calculation (Exposure Configuration), fire EN API with list of downloaded files and configuration, delete analyzed files
* [Receiving information](Documentation/ReceivingExposuresInformation.md) about detected exposures: register broadcast receiver about exposures, get information about exposures, store part of information (day of exposure, risk score and duration that is in 5 minutes intervals but max 30 minutes)
* [Reporting risk level](Documentation/ReportingRiskLevel.md) to the PWA: extract risk scores of saved exposures and calculate risk level, pass risk level to PWA
* [Removing historical data](Documentation/RemovingHistoricalData.md): remove information about exposures older than 14 days


## Project modules

- App - contains classes related to app's life cycle
- Common - contains app's extensions, helpers etc. 
- Components/PWA - module containing classes responsible for managing PWA's logic
- DependencyContainer - contains DI implementation, including factories for PWA and app's services
- Networking - implementation of app's networking logic, based on [Moya](https://github.com/Moya/Moya) framework
- Resources - module containing app's assets, entitlements and configuration files
- Services - module containing majority of apps business logic. Services are described in more detail in [services overview](#services-overview) section


## Services overview

* [AppManager](safesafe/Services/AppManager.swift) - service which holds info about app's first launch
* [ConfigManager](safesafe/Services/ConfigManager.swift) - service that provides a proper configuration based on currently used environment (Dev/Stage/Live)
* [DeviceCheckService](safesafe/Services/DeviceCheckService.swift) - service responsible for providing a valid verification payload for uploaded TEKs
* [KeychainService](safesafe/Services/KeychainService.swift) - service responsible for managing Keychain related activities
* [NotificationManager](safesafe/Services/NotificationManager.swift) - service responsible for managing push notification related activities
* [StoredDefaults](safesafe/Services/StoredDefaults.swift) - service managing logic related to UserDefaults
* [ServiceStatusManager](safesafe/Services/AppStatus/ServiceStatusManager.swift) - service that gathers data about statuses of permissions and states of Notifications and Exposure Notification services
* [BackgroundTasksService](safesafe/Services/ExposureNotification/BackgroundTasksService.swift) - service which is responsible for scheduling backround tasks in the app. Each background task is meant to perform an exposure detection, based on periodically downloaded TEKs
* [DiagnosisKeysDownloadService](safesafe/Services/ExposureNotification/DiagnosisKeysDownloadService.swift) - service responsible for downloading TEKs from the server
* [DiagnosisKeysUploadService](safesafe/Services/ExposureNotification/DiagnosisKeysUploadService.swift) - service responsible for uploading TEKs to the server
* [ExposureService](safesafe/Services/ExposureNotification/ExposureService.swift) - service responsible for implementing exposure detection part of Exposure Notification API
* [ExposureSummaryService](safesafe/Services/ExposureNotification/ExposureSummaryService.swift) - service responsible for providing information about potential exposure risk


## Environments

Application has 3 different environments: Dev, Stage and Live.

Each environment has different configuration files - they are respectively divided in `safesafe/Resources` directory. 
Each environment uses:
- \[env\].entitlements file
- Config-\[env\].plist file, which contains appropriate PWA links and (legacy) BlueTrace configurations
- \[env\].xcconfig and \[env\]Dist.xcconfig Xcode config files
- GoogleService-Info-\[env\].plist files (those names are modified in one of build scripts, so that for compilation phase file's name is changed to `GoogleService-Info.plist`)

There are two build configurations for each environment: debug and release


## Initial setup

Make sure you have [CocoaPods](https://cocoapods.org) and [XcodeGen](https://github.com/yonaskolb/XcodeGen) already installed.

To setup the project, proceed with following steps:
1. Open terminal and go to project's directory
3. Run `xcodegen generate` to generate .xcodeproj file
4. Run `pod install` to install necessary dependencies and generate .xcworkspace file

For convenience, there's a `rebuild.sh` script which performs actions mentioned above. Aditionally, it let's you select Xcode that you want to use to open the project (if you have multiple Xcode versions on your machine).
To launch it, type `sh rebuild.sh` in your console.

## ChangeLog

**4.3.1**
- Fix for incorrect date display for entries in Health Journal in PWA

**4.3.0**
- In code multilanguage support (no UI yet)
- Added validation for diagnosis keys upload
- Added debug panel for sharing uploaded payloads and logs
- Removed device check from uploaded payloads

**4.2.4**

- Changed telephone number and email
- Changed text copy on an onboarding view
- Removed some tips
- Added properties ENDeveloperRegion and ENAPIVersion to Info.plist for iOS 14

**4.2.3**

- Passing app version to PWA
- Updated certificates for pinning
- Updated Privacy Policy URL in appstore

**4.2.2**

- Fix for disabling of screen recording
- Replaced all fatalError and assertionFailure due to storing full user paths in binary file

**4.2.1**

- Manage large Diagnosis Keys batches
- Refactored keys upload process
- Bug fixes

**4.2.0**

- Removed online PWA
- Added PWA as a part of app code (offline)
- Bug fixes

**4.1.1**

- Added Exposure Notification API
- Added Background Download Task For Exposure Notification
- Added Support For Exposure Notification Incompatible Devices
- Added Content Hider for App Switcher
- Added Open Trace Stored Data Remover
- Simplified Onboarding
- Simplified Assesment Risk Test
- Icreased App Security
- Removed Open Trace Code


**3.0.2**

- Manage project settings with yml config files - XcodeGen added
- Debug console added for Stage and Dev configs
- Moved anonymous signIn to Firebase on app start
- Added custom Config.plist for every xcode configuration
- Disabled app idle timer
- Pass notification payload to webkit UI
- Fix for refreshing BlueTrace Temp ID
- Fix for deleting data from device
- Add GPL LICENSE file


**3.0.1**

- Added OpenTrace module for collecting BLE contacts


**2.0.1**

- Basic version with PWA, and notifications
