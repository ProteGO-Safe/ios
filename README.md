# ProteGO Safe

ProteGO Safe is a publicly open reference implementation of OpenTrace.

To get more information about OpenTrace itself, please visit this [repository](https://github.com/opentrace-community/opentrace-ios).


### Initial setup
Make sure you have [CocoaPods](https://cocoapods.org) and [XcodeGen](https://github.com/yonaskolb/XcodeGen) already installed.

To setup the project, proceed with following steps:
1. Open terminal and go to project's directory
2. Run `git submodule update --init --recursive` to fetch OpenTrace repo
3. Run `xcodegen generate` to generate .xcodeproj file
4. Run `pod install` to install necessary dependencies 

### Configuration
As app relies on OpenTrace implementation, there's a need for some Firebase functions setup. For more details, please visit [OpenTrace cloud functions repository](https://github.com/opentrace-community/opentrace-cloud-functions).

- After setting up Firebase project, you need to put proper `GoogleService-Info.plist` files in respective directories.
```
|-- /safesafe
    |-- /Resources
        |-- /Dev
            |-- GoogleService-Info.plist
        |-- /Live
            |-- GoogleService-Info.plist
        |-- /Stage
            |-- GoogleService-Info.plist
```

- You can find a `Config-live.plist` file under `safesafe/Resources`. It has necessary information for Bluetrace and PWA setup. For security reasons, there's only a `Live` configuration available publicly.
