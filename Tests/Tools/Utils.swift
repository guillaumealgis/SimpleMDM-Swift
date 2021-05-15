//
//  Copyright 2021 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

@testable import SimpleMDM

internal func loadFixture(_ name: String) -> Data {
    let filename = name + ".json"
    let fixturesDirectory = fixturesDirectoryURLRelativeToCurrentFile()
    let urlIfFound = url(forFileNamed: filename, in: fixturesDirectory)
    guard let url = urlIfFound else {
        fatalError("Fixture \"\(name)\" not found in fixtures directory \"\(fixturesDirectory.absoluteString)\"")
    }
    guard let fixture = try? Data(contentsOf: url) else {
        fatalError("Error loading data at URL \"\(url)\"")
    }
    return fixture
}

// Not a great way to retrieve the fixtures paths, but as of now SwiftPM doesn't support embeding resources.
// See discussion at https://forums.swift.org/t/swift-pm-bundles-and-resources/13981/.
internal func fixturesDirectoryURLRelativeToCurrentFile() -> URL {
    let currentFileURL = URL(fileURLWithPath: #file)

    // We expect to find the 'Fixtures' directory in 'Tests/Fixtures',
    // so in '../Fixtures' relative to this file.
    var fixturesDirectoryURL = currentFileURL
    fixturesDirectoryURL.deleteLastPathComponent()
    fixturesDirectoryURL.deleteLastPathComponent()
    fixturesDirectoryURL.appendPathComponent("Fixtures")

    return fixturesDirectoryURL
}

internal func url(forFileNamed filename: String, in directory: URL) -> URL? {
    var isDirectory: ObjCBool = false
    let directoryExists = FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory)
    guard directoryExists, isDirectory.boolValue else {
        return nil
    }

    let resourceKeys: [URLResourceKey] = [.isDirectoryKey]
    let enumerationOptions: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
    guard let directoryEnumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: resourceKeys, options: enumerationOptions, errorHandler: nil) else {
        return nil
    }

    for case let fileURL as URL in directoryEnumerator where fileURL.lastPathComponent == filename {
        return fileURL
    }

    return nil
}

internal extension SimpleMDM {
    convenience init(sessionMock: URLSessionMock) {
        self.init()

        let networking = Networking(urlSession: sessionMock)
        networking.apiKey = "AVeryRandomAPIKey"
        self.networking = networking
    }
}
