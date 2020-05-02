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
  pod 'PromiseKit', '~> 6.8'
  
  pod 'DBDebugToolkit', :configurations => ['Dev', 'Stage']

end

target 'safesafe' do
  pods_definition
end
