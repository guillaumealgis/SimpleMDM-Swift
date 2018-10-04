//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

@testable import SimpleMDM
import XCTest

internal class AppTests: XCTestCase {
    func testGetAllApps() {
        let json = loadFixture("Apps")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.getAll { result in
            guard case let .success(apps) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(apps.count, 5)
        }
    }

    func testGetAnApp() {
        let json = loadFixture("App_SimpleMDM")
        let session = URLSessionMock(data: json, responseCode: 200)
        SimpleMDM.useSessionMock(session)

        App.get(id: 17_635) { result in
            guard case let .success(app) = result else {
                return XCTFail("Expected .success, got \(result)")
            }
            XCTAssertEqual(app.bundleIdentifier, "com.unwiredrev.DeviceLink.public")
        }
    }

    func testErrorWhileFetchingAnAppManagedConfigs() {
        let json = """
          {
            "errors": []
          }
        """.data(using: .utf8)

        let session = URLSessionMock(routes: [
            "/api/v1/apps/17635": Response(data: loadFixture("App_SimpleMDM")),
            "/api/v1/apps/17635/managed_configs": Response(data: json, code: 500)
        ])
        SimpleMDM.useSessionMock(session)

        App.get(id: 17_635) { appResult in
            guard case let .success(app) = appResult else {
                return XCTFail("Expected .success, got \(appResult)")
            }

            app.managedConfigs.next { managedConfigsResult in
                guard case let .failure(error) = managedConfigsResult else {
                    return XCTFail("Expected .failure, got \(managedConfigsResult)")
                }
                guard let simpleMDMError = error as? SimpleMDMError else {
                    return XCTFail("Expected error to be an SimpleMDMError, got \(error)")
                }
                XCTAssertEqual(simpleMDMError, SimpleMDMError.unknown(httpCode: 500))
            }
        }
    }

    func testGetAnAppRelatedManagedConfigs() {
        let session = URLSessionMock(routes: [
            "/api/v1/apps/17635": Response(data: loadFixture("App_SimpleMDM")),
            "/api/v1/apps/17635/managed_configs": Response(data: loadFixture("ManagedConfigs"))
        ])
        SimpleMDM.useSessionMock(session)

        App.get(id: 17_635) { appResult in
            guard case let .success(app) = appResult else {
                return XCTFail("Expected .success, got \(appResult)")
            }

            app.managedConfigs.next { managedConfigsResult in
                guard case let .success(managedConfigs) = managedConfigsResult else {
                    return XCTFail("Expected .success, got \(managedConfigsResult)")
                }
                XCTAssertEqual(managedConfigs.map { $0.key }, ["customer_name", "User IDs", "Device values"])
                XCTAssertEqual(managedConfigs.map { $0.value }, ["ACME Inc.", "1,53,3", "\"$imei\",\"$udid\""])
                XCTAssertEqual(managedConfigs.map { $0.valueType }, ["string.", "integer array", "string array"])
            }
        }
    }
}
