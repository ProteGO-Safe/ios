
# Change Log

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 4.3.1
- Fix for incorrect date display for entries in Health Journal in PWA

## 4.3.0
- In code multilanguage support (no UI yet)
- Added validation for diagnosis keys upload
- Added debug panel for sharing uploaded payloads and logs
- Removed device check from uploaded payloads

## 4.2.4

- Changed telephone number and email
- Changed text copy on an onboarding view
- Removed some tips
- Added properties ENDeveloperRegion and ENAPIVersion to Info.plist for iOS 14

## 4.2.3

- Passing app version to PWA
- Updated certificates for pinning
- Updated Privacy Policy URL in appstore

## 4.2.2s

- Fix for disabling of screen recording
- Replaced all fatalError and assertionFailure due to storing full user paths in binary file

## 4.2.1

- Manage large Diagnosis Keys batches
- Refactored keys upload process
- Bug fixes

## 4.2.0

- Removed online PWA
- Added PWA as a part of app code (offline)
- Bug fixes

## 4.1.1

- Added Exposure Notification API
- Added Background Download Task For Exposure Notification
- Added Support For Exposure Notification Incompatible Devices
- Added Content Hider for App Switcher
- Added Open Trace Stored Data Remover
- Simplified Onboarding
- Simplified Assesment Risk Test
- Icreased App Security
- Removed Open Trace Code


## 3.0.2

- Manage project settings with yml config files - XcodeGen added
- Debug console added for Stage and Dev configs
- Moved anonymous signIn to Firebase on app start
- Added custom Config.plist for every xcode configuration
- Disabled app idle timer
- Pass notification payload to webkit UI
- Fix for refreshing BlueTrace Temp ID
- Fix for deleting data from device
- Add GPL LICENSE file


## 3.0.1

- Added OpenTrace module for collecting BLE contacts


## 2.0.1

- Basic version with PWA, and notifications
