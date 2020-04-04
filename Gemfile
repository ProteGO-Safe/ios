source "https://rubygems.org"

gem "fastlane", '~> 2.144.0'
gem "badge", '~> 0.10.0'
gem "cocoapods", '~> 1.9.1'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
