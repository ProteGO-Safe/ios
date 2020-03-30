platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

def crashlytics
  # Due to https://github.com/CocoaPods/CocoaPods/issues/9658 we have to link all Crashlytics dependencies separately
  # Initially we've tried to link Firebase/Crashlytics with version 6.21.0
  # When cocoapods would fix this issue, we might come back to:
  # pod 'Firebase/Crashlytics', '6.21.0', :configurations => ['Debug_dev', 'Release_dev']
  pod 'Firebase', '6.21.0', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseAnalyticsInterop', '1.5.0', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseCore', '6.6.5', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseCoreDiagnostics', '1.2.2', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseCoreDiagnosticsInterop', '1.2.0', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseCrashlytics', '4.0.0-beta.6', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseInstallations', '1.1.1', :configurations => ['Debug_dev', 'Release_dev']
  pod 'GoogleDataTransport', '5.1.0', :configurations => ['Debug_dev', 'Release_dev']
  pod 'GoogleDataTransportCCTSupport', '2.0.1', :configurations => ['Debug_dev', 'Release_dev']
  pod 'GoogleUtilities', '6.5.2', :configurations => ['Debug_dev', 'Release_dev']
  pod 'PromisesObjC', '1.2.8', :configurations => ['Debug_dev', 'Release_dev']
  pod 'nanopb', '0.3.9011', :configurations => ['Debug_dev', 'Release_dev']
  pod 'FirebaseAnalytics', '6.4.0', :configurations => ['Debug_dev', 'Release_dev']
  pod 'GoogleAppMeasurement', '6.4.0', :configurations => ['Debug_dev', 'Release_dev']
end

target 'ProteGO' do
  crashlytics
  pod 'BugfenderSDK', '1.8', :configurations => ['Debug_dev', 'Release_dev']
  pod 'SwiftLint', '0.39.1'
  pod 'SwiftGen', '6.1.0'
end

target 'ProteGOTests' do
  # Tests are failing then it's not linked, maybe some issue with canImport() 
  # not working in targets referenced by @testable
  crashlytics
end