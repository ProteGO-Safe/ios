# ProteGO Safe iOS App

![Logo](./ghImages/logo.png "ProteGO Safe")

## Project overview

This is an iOS application for [ProteGO Safe project](https://github.com/ProteGO-Safe/specs) and it implements two main features:
* User daily triage - //TODO description to be provided or linked to main documentation//
* Contact tracing - module that is fully based on [Exposure Notification API](https://developer.apple.com/documentation/exposurenotification) provided by Google and Apple and it's goal is to inform people of potential exposure to COVID-19.

Application is structured based MVVM-C pattern, where presentation (UI) layer is almost fully realized with a single UIViewController with a WKWebView that loads a website application called 'PWA' (Progressive Web App). PWA is responsible for GUI, user interaction and 'User daily triage' feature. Website app interacts with native code through the JavaScript bridge.


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
* [BackgroundTaskService](safesafe/Services/ExposureNotification/BackgroundTaskService.swift) - service which is responsible for scheduling backround tasks in the app. Each background task is meant to perform an exposure detection, based on periodically downloaded TEKs
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


## ChangeLog


4.1.0 (TBD)

Exposure Notification API added
OpenTrace module fully removed together with all collected data


3.0.2

Manage project settings with yml config files - XcodeGen added
Debug console added for Stage and Dev configs
Moved anonymous signIn to Firebase on app start
Added custom Config.plist for every xcode configuration
Disabled app idle timer
Pass notification payload to webkit UI
Fix for refreshing BlueTrace Temp ID
Fix for deleting data from device
Add GPL LICENSE file


3.0.1

Added OpenTrace module for collecting BLE contacts


2.0.1

Basic version with PWA, and notifications