# SygicMapsKit - iOS

A powerful open-source library based on [Sygic Maps SDK][SygicMapsSDK] which can be used to display rich map content and interact with it. It is using UI components from [Sygic UI Kit][SygicUIKit] (if you are looking for an android version, you can find it [here][AndroidMapsKit]) 

![Sygic][SygicLogo]

## Sample Application

To get familiar with all the features available, you can first try out our sample application. To run the application, clone the repo, and run `pod install` from the `Example` directory first. Open `SygicMapsKit.xcworkspace` and build. Read about samples and how to use them at our [wiki][MapsKitWiki]

[![Example1][Example1Thumbnail]][Example1][![Example2][Example2Thumbnail]][Example2][![Example3][Example3Thumbnail]][Example3][![Example4][Example4Thumbnail]][Example4]

## Requirements

* **Request the Sygic API key**. To start developing with Sygic Maps SDK, please [fill this form][SygicAPIKey] and get your API key.
* Call `SYMKApiKeys.set(appKey: String, appSecret: String)` before using MapsKit.
* Swift 4.2

## Installation

SygicMapsKit is available through [CocoaPods][CocoaPods]. To install
it, simply add the following line to your Podfile:

```ruby
pod 'SygicMapsKit'
```

### Bitcode

Unfortunately SygicMaps framework does not support bitcode yet.
In the meantime you have to disable bitcode in your application as well, or use [post_install script][samplePodfile] in podfile to disable bitcode in all targets.

### Permissions

If you would like to use location based features from framework, please make sure your application Information Property List Key (Info.plist) contains necessary permission keys ([NSLocationWhenInUseUsageDescription][LocationInUse] or [NSLocationAlwaysAndWhenInUseUsageDescription][LocationAllways]) 

## Help

First read the [Wiki][MapsKitWiki] page, then try to search on [Stackoverflow][SygicMobileSDKiOS] or visit the GitHub [issues][MapsKitIssues] page.

## Authors

  * **Jakub Cali­k** - *Primary contributor* - [jcaliksygic][jcalikGithub]
  * **Jakub Kracina** - *Primary contributor* - [Kraci][KraciGithub]
  * **Marek Dovjak** - *Primary contributor* - [marekdovjak][marekdovjakGithub]

## License

```
This project is licensed under the MIT License

Copyright (c) 2019 - Sygic a.s.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
[//]: # (Comment)

[KraciGithub]: <https://github.com/Kraci>
[jcalikGithub]: <https://github.com/jcaliksygic>
[marekdovjakGithub]: <https://github.com/marekdovjak>

[SygicAPIKey]: <https://www.sygic.com/enterprise/get-api-key/>
[SygicMapsSDK]: <https://www.sygic.com/enterprise/maps-navigation-sdk-api-developers>
[SygicUIKit]: <https://github.com/Sygic/sygic-ui-kit-ios>
[AndroidMapsKit]: <https://github.com/Sygic/sygic-maps-kit-android>
[SygicLogo]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/sygic_logo.png>
[CocoaPods]: <https://cocoapods.org>
[MapsKitWiki]: <https://github.com/Sygic/sygic-maps-kit-ios/wiki>
[SygicMobileSDKiOS]: <https://stackoverflow.com/questions/tagged/ios+sygic-mobile-sdk>
[MapsKitIssues]: <https://github.com/Sygic/sygic-maps-kit-ios/issues>

[Example1]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example1.png>
[Example2]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example2.png>
[Example3]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example3.png>
[Example4]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example4.png>
[Example1Thumbnail]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example1_thumbnail.png>
[Example2Thumbnail]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example2_thumbnail.png>
[Example3Thumbnail]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example3_thumbnail.png>
[Example4Thumbnail]: <https://raw.githubusercontent.com/Sygic/sygic-maps-kit-ios/master/Assets/example4_thumbnail.png>

[LocationInUse]: <https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_when-in-use_authorization>
[LocationAllways]: <https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_always_authorization>
[samplePodfile]: <https://github.com/Sygic/sygic-maps-kit-ios/blob/develop/Example/Podfile>
