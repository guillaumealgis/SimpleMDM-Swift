# Contributing

If you wish to contribute to SimpleMDM-Swift please fork the repository and send a pull request. Contributions and feature requests are always welcome, please do not hesitate to raise an issue!

Contributors and any people interacting on this project are expected to adhere to its code of conduct. See CODE_OF_CONDUCT.md for details.

## Getting Started

To start contributing to SimpleMDM-Swift, you need the latest version of Xcode on your machine.
After cloning the project, run the following command to generate the project's .xcodeproj:

```shell
swift package generate-xcodeproj
```

You can then start working on the project by opening the newly created `SimpleMDM-Swift.xcodeproj` file.

## Tools needed

All tools and non-library dependencies are listed in the Brewfile at the root of the project.

To install them on your machine, you need to have [Homebrew](https://brew.sh) installed on your machine, and then run:

```shell
brew bundle
```

## Re-generating code

Some parts of this library are automatically generated using [Sourcery](https://github.com/krzysztofzablocki/Sourcery). Run this command to regenerate code as needed:

```shell
sourcery
```

Because whitespace management in .stencil templates can be a bit complicated, generated code will not always follow the coding-style rules set by SwiftFormat. You should always run SwiftFormat on the generated code after running Sourcery:

```shell
# Always prefer this command combo
sourcery; swiftformat Sources
```

## Re-generating documentation

The documentation is generated using [`swift-doc`](https://github.com/SwiftDocOrg/swift-doc). To re-generate the documentation after making a change, use:

```shell
swift doc generate Sources --module-name SimpleMDM-Swift --format html --output docs --base-url https://guillaumealgis.github.io/SimpleMDM-Swift/
```

### Previewing the documentation locally

You can preview the changes made to the documentation locally before pushing to the repository by running this command instead:

```shell
swift doc generate Sources --module-name SimpleMDM-Swift --format html --base-url http://localhost:9000
```

The documentation will be generated in `.build/documentation/` (you should not generate the local documentation within `docs/` to prevent pushing it to the repository with a local base URL by mistake).

You'll need some webserver running locally on port 9000 to view the documentation. If you have no preference, python has a built-in webserver and is shipped with macOS:

```shell
cd .build/documentation/
/usr/bin/python -m SimpleHTTPServer 9000
```
