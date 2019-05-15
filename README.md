# SimpleMDM-Swift

[![MIT](https://img.shields.io/github/license/guillaumealgis/SimpleMDM-Swift.svg)](https://tldrlegal.com/license/mit-license)
[![Build Status](https://img.shields.io/travis/guillaumealgis/SimpleMDM-Swift/master.svg)](https://travis-ci.org/guillaumealgis/SimpleMDM-Swift)
[![Codecov](https://img.shields.io/codecov/c/github/guillaumealgis/SimpleMDM-Swift/master.svg)](https://codecov.io/gh/guillaumealgis/SimpleMDM-Swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SimpleMDM-Swift.svg)](https://cocoapods.org/pods/SimpleMDM-Swift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-blue.svg)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/SimpleMDM-Swift.svg)](https://alamofire.github.io/Alamofire)
[![Twitter](https://img.shields.io/badge/twitter-@guillaumealgis-00aced.svg)](https://twitter.com/guillaumealgis)

SimpleMDM-Swift is a cross-platform (iOS, macOS, tvOS, watchOS) SDK to access the SimpleMDM API written in Swift.

**Please Note**: This library is not officially supported by SimpleMDM. It does not currently wrap the complete functionality of the SimpleMDM API. Use at your own risk.

## Features

* Read-only access to all exposed resources (Device, App, etc.) of the REST API
* Supports the pagination API introduced August 15, 2018
* Type-safe
* Asynchronous API, relying on [Result type](https://www.swiftbysundell.com/posts/the-power-of-result-types-in-swift)
* High test coverage
* 100% documented

##### System requirements

+ Deployment target of iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
+ Xcode 10.2+
+ Swift 5.0.1+

## Usage

Full documentation is available here: [https://guillaumealgis.github.io/SimpleMDM-Swift/](https://guillaumealgis.github.io/SimpleMDM-Swift/)

```swift
// Just set this once in your applicationDidBecomeActive method
SimpleMDM.APIKey = "233b7a3058694652ae6f62acfcba8be7"

// Get the device with id 42
Device.get(id: 42) { result in
    switch result {
    case let .failure(error):
        print("Could not get device: \(error)")
    case let .success(device):
        print(device.name)
    }
}

// Get all device groups
DeviceGroup.getAll { result in
    switch result {
    case let .failure(error):
        print("Could not get device groups: \(error)")
    case let .success(deviceGroups):
        print(deviceGroups.map { $0.name })
    }
}
```

## Installation

### CocoaPods

To integrate SimpleMDM-Swift into your Xcode project using [CocoaPods](https://cocoapods.org), specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

target '<Your Target Name>' do
    pod 'SimpleMDM-Swift', '~> 0.1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

----

### Carthage

To integrate SimpleMDM-Swift into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your Cartfile:

`github "guillaumealgis/SimpleMDM-Swift"`

Run `carthage update` to build the framework and drag the built SimpleMDM-Swift.framework into your Xcode project and update your run scripts as appropriate. For additional support, please visit the Carthage [documentation](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

## Apps using SimpleMDM-Swift

I'd love to hear what you have used SimpleMDM-Swift for, if you would like your app displayed here, please send a pull request!

## Contributing

If you wish to contribute to SimpleMDM-Swift please fork the repository and send a pull request. Contributions and feature requests are always welcome, please do not hesitate to raise an issue!

Contributors and any people interacting on this project are expected to adhere to its code of conduct. See CODE\_OF\_CONDUCT.md for details.

## License

SimpleMDM-Swift is released under the MIT license. See LICENSE.md for details.

## Related Projects

- [The SimpleMDM REST API documentation](https://simplemdm.com/docs/api/)
- [SimpleMDM/simplemdm-ruby](https://github.com/SimpleMDM/simplemdm-ruby) - Ruby library
- [SteveKueng/simpleMDMpy](https://github.com/SteveKueng/simpleMDMpy) - Python library
