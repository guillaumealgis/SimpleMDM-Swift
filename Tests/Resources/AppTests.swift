//
//  Copyright 2022 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AppTests: XCTestCase {
    func testGetAllApps() async throws {
        let json = loadFixture("Apps")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let apps = try await App.all.collect()
        XCTAssertEqual(apps.count, 5)
    }

    func testGetAnApp() async throws {
        let json = loadFixture("App_SimpleMDM")
        let sessionMock = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let app = try await App.get(id: 17_635)
        XCTAssertEqual(app.bundleIdentifier, "com.unwiredrev.DeviceLink.public")
    }

    func testErrorWhileFetchingAnAppManagedConfigs() async throws {
        let json = """
          {
            "errors": []
          }
        """.data(using: .utf8)

        let sessionMock = URLSessionMock(routes: [
            "/api/v1/apps/17635": Response(data: loadFixture("App_SimpleMDM")),
            "/api/v1/apps/17635/managed_configs?limit=100": Response(data: json, code: 500)
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let app = try await App.get(id: 17_635)

        await XCTAssertAsyncThrowsError({
            _ = try await app.managedConfigs.collect()
        }) { error in
            guard let simpleMDMError = error as? SimpleMDMError else {
                return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
            }
            XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 500))
        }
    }

    func testGetAnAppRelatedManagedConfigs() async throws {
        let sessionMock = URLSessionMock(routes: [
            "/api/v1/apps/17635": Response(data: loadFixture("App_SimpleMDM")),
            "/api/v1/apps/17635/managed_configs?limit=100": Response(data: loadFixture("ManagedConfigs"))
        ])
        SimpleMDM.shared.replaceNetworkingSession(sessionMock)

        let expectedKeys = ["customer_name", "User IDs", "Device values"]
        let expectedValues = ["ACME Inc.", "1,53,3", "\"$imei\",\"$udid\""]
        let expectedValueTypes = ["string", "integer array", "string array"]

        let app = try await App.get(id: 17_635)

        var i = 0
        for try await managedConfig in app.managedConfigs {
            XCTAssertEqual(managedConfig.key, expectedKeys[i])
            XCTAssertEqual(managedConfig.value, expectedValues[i])
            XCTAssertEqual(managedConfig.valueType, expectedValueTypes[i])
            i += 1
        }
    }
}
