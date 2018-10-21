# SimpleMDM-Swift

#### Supports Swift 4.2

SimpleMDM-Swift is a cross-platform (iOS, macOS, tvOS, watchOS) SDK to access the SimpleMDM API written in Swift.

**Please Note**: This library is not officially supported by SimpleMDM. It does not currently wrap the complete functionality of the SimpleMDM API. Use at your own risk.

## Features

* Read-only access to all exposed resources (Device, App, etc.) of the REST API
* Supports the pagination API introduced August 15, 2018
* Type-safe
* Asynchronous, relying on [Result type](https://www.swiftbysundell.com/posts/the-power-of-result-types-in-swift)
* High unit test coverage

##### System requirements

+ Deployment target of iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
+ Xcode 10.0+
+ Swift 4.2+

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
use_frameworks!

target '<Your Target Name>' do
    pod 'SimpleMDM-Swift'
end
```

Then, run the following command:

```bash
$ pod install
```

----

### Carthage

To integrate Euclid into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your Cartfile:

`github "guillaumealgis/SimpleMDM-Swift"`

Run `carthage update` to build the framework and drag the built Euclid.framework into your Xcode project and update your run scripts as appropriate. For additional support, please visit the Carthage [documentation](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

----

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but SimpleMDM-Swift does support its use on supported platforms.

Once you have your Swift package set up, adding SimpleMDM-Swift as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

#### Swift 4

```swift
dependencies: [
    .package(url: "https://github.com/guillaumealgis/SimpleMDM-Swift.git", from: "0.0.0")
]
```

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
