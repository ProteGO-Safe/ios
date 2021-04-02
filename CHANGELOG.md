
# Change Log

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 4.11.0
- Updated UI

## 4.10.0
- Added new file storage method
- Split current JSON data to multiple smaller data files to prevent over downloading unwanted data
- Enhanced view of the app home screen, which now includes more detailed statistics on vaccination and infections
- New screen with detailed statistics and graphs on vaccination (number of people vaccinated, doses, adverse reactions) and infections (number of people infected, recovered, deaths, causes of death and tests)
- Added information on vaccination and registration rules with redirection to registration, vaccination request and helpline

## 4.9.1
- Added Vaccination stats to dashboard

## 4.9.0
- Added COVID daily stats
- Added subscription for COVID daily stats push notifications
- Added ability to unsubscribe from daily COVID stats push notification
- Added localized push notifications
- Added push notifications history
- Added deep linking for push notifications
- Added Universal Links for deep linking
- Added local notifications (aka Districts Info) to notifications history
- Removed passing push notification payload to UI (aka PWA)
- Added Exposure Notificaticarion stats (keys count, analyze history, risk check)
- Added Simulate Risk CHeck to Debug Panel
- Added fetching CDN keys to Debug Panel
- Changed the way of triggering to show Debug Panel in Stage builds (use shake gesture)

## 4.8.0
- Added ability for manual delete exposure risk info


## 4.7.0
- Omit package analysis on very first app run
- Added ability for sign-in for covid-19 test
- Added js contract for high risk and covid-19 test
- Added simulate exposure risk to debug panel

## 4.6.0
- Added restricted districts feature
- Added subscribing for notification for restricted districts
- Small fixes for JS contract
- Added ability to test districts changes notification to debug panel
- Translations update
- Fix for manage max exposure notifications key amount per day
- Remove debug logging from iOS < 13.5

## 4.5.0
- Manage user diagnosis keys share rejection 
- Prevents url requests caching
- Added webkit local storage dump for debug panel in stage builds
- Translations update
- Fix for language reset on data erase
- Added PWA to .gitignore file according to download it on CI/CD

## 4.4.0
- Added translations for English and Ukrainian languages
- Ability of change language in app runtime
- Fix for multiple language managing
- Fix for "no internet" alert on keys upload
- Fix for disclaimer and contrib file
- Remove redundant data logging

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

## 4.2.2
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
