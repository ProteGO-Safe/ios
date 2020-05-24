# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def pods_definition
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SnapKit', '5.0.1'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Functions'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Storage'
  pod 'PromiseKit', '~> 6.8'
  pod 'Moya', '~> 14.0'
  pod 'ZIPFoundation', '~> 0.9'
  pod 'RealmSwift', '~> 5.0.0'
  pod 'KeychainAccess', '~> 4.2.0'
  
  pod 'DBDebugToolkit', :configurations => ['Dev', 'DevDist', 'Stage', 'StageDebug', 'LiveDebug', 'LiveAdhoc']

end

target 'safesafe' do
  pods_definition
end
