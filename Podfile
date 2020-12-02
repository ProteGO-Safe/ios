# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def pods_definition
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SnapKit', '5.0.1'
  pod 'Firebase/Functions'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/RemoteConfig'
  pod 'PromiseKit', '~> 6.8'
  pod 'Moya', '~> 14.0'
  pod 'ZIPFoundation', '~> 0.9'
  pod 'KeychainAccess', '~> 4.2.0'
  pod 'TrustKit', '~> 1.6.5'
  pod 'Siren', '~> 5.4.0'
  pod 'RealmSwift', '~> 5.0.0'
  
  pod 'DBDebugToolkit', :configurations => ['Dev', 'DevDist', 'Stage', 'StageDebug', 'StageScreencast', 'LiveDebug', 'LiveAdhoc']

end

target 'safesafe' do
  pods_definition
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
end
