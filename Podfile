platform :ios, '12.0'
inhibit_all_warnings!
use_modular_headers!

def shared
  # Tests are failing then it's not linked, maybe some issue with canImport() 
  # not working in targets referenced by @testable
  pod 'Firebase/Crashlytics', '6.21.0', :configurations => ['Debug_dev', 'Release_dev']
end

target 'Anna' do
  shared
  pod 'BugfenderSDK', '1.8', :configurations => ['Debug_dev', 'Release_dev']
  pod 'SwiftLint', '0.39.1'
end

target 'AnnaTests' do
  shared
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end