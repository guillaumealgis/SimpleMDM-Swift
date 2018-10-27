// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
//  Copyright 2018 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

internal extension Resource {
    func decodeAndValidateType<K: CodingKey>(forKey key: K, in container: KeyedDecodingContainer<K>, expecting expectedType: String) throws {
        let type = try container.decode(String.self, forKey: key)
        guard type == expectedType else {
            let description = "Expected type of resource to be \"\(expectedType)\" but got \"\(type)\""
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: description)
        }
    }
}

// swiftlint:disable file_length function_body_length

// MARK: - Account
extension Account: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "account"
    }
}

extension Account: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case name
        case appleStoreCountryCode
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)
        appleStoreCountryCode = try attributes.decode(String.self, forKey: .appleStoreCountryCode)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "account")
    }
}

// MARK: - App

extension App: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "apps"
    }
}

extension App: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case name
        case appType
        case bundleIdentifier
        case itunesStoreId
        case version
        case managedConfigs
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)
        appType = try attributes.decode(String.self, forKey: .appType)
        bundleIdentifier = try attributes.decode(String.self, forKey: .bundleIdentifier)
        itunesStoreId = try attributes.decodeIfPresent(Int.self, forKey: .itunesStoreId)
        version = try attributes.decodeIfPresent(String.self, forKey: .version)
        managedConfigs = NestedResourceCursor<App, ManagedConfig>(parentId: id)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "app")
    }
}

// MARK: - App.ManagedConfig

extension App.ManagedConfig: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "managed_configs"
    }
}

extension App.ManagedConfig: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case key
        case value
        case valueType
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        key = try attributes.decode(String.self, forKey: .key)
        value = try attributes.decode(String.self, forKey: .value)
        valueType = try attributes.decode(String.self, forKey: .valueType)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "managed_config")
    }
}

// MARK: - AppGroup

extension AppGroup: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "app_groups"
    }
}

extension AppGroup: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
        case relationships
    }

    private enum AttributesKeys: String, CodingKey {
        case name
        case autoDeploy
    }

    private enum RelationshipKeys: String, CodingKey {
        case apps
        case deviceGroups
        case devices
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)
        autoDeploy = try attributes.decode(Bool.self, forKey: .autoDeploy)

        let relationships = try payload.nestedContainer(keyedBy: RelationshipKeys.self, forKey: .relationships)
        apps = try relationships.decode(RelatedToMany<App>.self, forKey: .apps)
        deviceGroups = try relationships.decode(RelatedToMany<DeviceGroup>.self, forKey: .deviceGroups)
        devices = try relationships.decode(RelatedToMany<Device>.self, forKey: .devices)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "app_group")
    }
}

// MARK: - CustomAttribute

extension CustomAttribute: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "custom_attributes"
    }
}

extension CustomAttribute: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case name
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "custom_attribute")
    }
}

// MARK: - CustomConfigurationProfile

extension CustomConfigurationProfile: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "custom_configuration_profiles"
    }
}

extension CustomConfigurationProfile: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
        case relationships
    }

    private enum AttributesKeys: String, CodingKey {
        case name
    }

    private enum RelationshipKeys: String, CodingKey {
        case deviceGroups
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)

        let relationships = try payload.nestedContainer(keyedBy: RelationshipKeys.self, forKey: .relationships)
        deviceGroups = try relationships.decode(RelatedToMany<DeviceGroup>.self, forKey: .deviceGroups)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "custom_configuration_profile")
    }
}

// MARK: - Device

extension Device: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "devices"
    }
}

extension Device: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
        case relationships
    }

    private enum AttributesKeys: String, CodingKey {
        case uniqueIdentifier
        case serialNumber
        case imei
        case meid
        case iccid
        case name
        case deviceName
        case lastSeenAt
        case status
        case modelName
        case model
        case productName
        case osVersion
        case buildVersion
        case modemFirmwareVersion
        case carrierSettingsVersion
        case deviceCapacity
        case availableDeviceCapacity
        case batteryLevel
        case bluetoothMac
        case wifiMac
        case currentCarrierNetwork
        case simCarrierNetwork
        case subscriberCarrierNetwork
        case phoneNumber
        case cellularTechnology
        case voiceRoamingEnabled
        case dataRoamingEnabled
        case isRoaming
        case subscriberMcc
        case subscriberMnc
        case simmcc
        case simmnc
        case currentMcc
        case currentMnc
        case hardwareEncryptionCaps
        case passcodePresent
        case passcodeCompliant
        case passcodeCompliantWithProfiles
        case filevaultEnabled
        case filevaultRecoveryKey
        case firmwarePasswordEnabled
        case firmwarePassword
        case isSupervised
        case isDepEnrollment
        case isUserApprovedEnrollment
        case isDeviceLocatorServiceEnabled
        case isDoNotDisturbInEffect
        case personalHotspotEnabled
        case itunesStoreAccountIsActive
        case lastCloudBackupDate
        case isActivationLockEnabled
        case isCloudBackupEnabled
        case locationLatitude
        case locationLongitude
        case locationAccuracy
        case locationUpdatedAt
    }

    private enum RelationshipKeys: String, CodingKey {
        case deviceGroup
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        uniqueIdentifier = try attributes.decode(String.self, forKey: .uniqueIdentifier)
        serialNumber = try attributes.decode(String.self, forKey: .serialNumber)
        imei = try attributes.decodeIfPresent(String.self, forKey: .imei)
        meid = try attributes.decodeIfPresent(String.self, forKey: .meid)
        iccid = try attributes.decodeIfPresent(String.self, forKey: .iccid)
        name = try attributes.decode(String.self, forKey: .name)
        deviceName = try attributes.decode(String.self, forKey: .deviceName)
        lastSeenAt = try attributes.decode(Date.self, forKey: .lastSeenAt)
        status = try attributes.decode(String.self, forKey: .status)
        modelName = try attributes.decode(String.self, forKey: .modelName)
        model = try attributes.decode(String.self, forKey: .model)
        productName = try attributes.decode(String.self, forKey: .productName)
        osVersion = try attributes.decode(String.self, forKey: .osVersion)
        buildVersion = try attributes.decode(String.self, forKey: .buildVersion)
        modemFirmwareVersion = try attributes.decodeIfPresent(String.self, forKey: .modemFirmwareVersion)
        carrierSettingsVersion = try attributes.decodeIfPresent(String.self, forKey: .carrierSettingsVersion)
        deviceCapacity = try attributes.decode(Double.self, forKey: .deviceCapacity)
        availableDeviceCapacity = try attributes.decode(Double.self, forKey: .availableDeviceCapacity)
        batteryLevel = try attributes.decode(String.self, forKey: .batteryLevel)
        bluetoothMac = try attributes.decode(String.self, forKey: .bluetoothMac)
        wifiMac = try attributes.decode(String.self, forKey: .wifiMac)
        currentCarrierNetwork = try attributes.decodeIfPresent(String.self, forKey: .currentCarrierNetwork)
        simCarrierNetwork = try attributes.decodeIfPresent(String.self, forKey: .simCarrierNetwork)
        subscriberCarrierNetwork = try attributes.decodeIfPresent(String.self, forKey: .subscriberCarrierNetwork)
        phoneNumber = try attributes.decodeIfPresent(String.self, forKey: .phoneNumber)
        cellularTechnology = try attributes.decode(Int.self, forKey: .cellularTechnology)
        voiceRoamingEnabled = try attributes.decodeIfPresent(Bool.self, forKey: .voiceRoamingEnabled)
        dataRoamingEnabled = try attributes.decode(Bool.self, forKey: .dataRoamingEnabled)
        isRoaming = try attributes.decode(Bool.self, forKey: .isRoaming)
        subscriberMcc = try attributes.decodeIfPresent(String.self, forKey: .subscriberMcc)
        subscriberMnc = try attributes.decodeIfPresent(String.self, forKey: .subscriberMnc)
        simmcc = try attributes.decodeIfPresent(String.self, forKey: .simmcc)
        simmnc = try attributes.decodeIfPresent(String.self, forKey: .simmnc)
        currentMcc = try attributes.decodeIfPresent(String.self, forKey: .currentMcc)
        currentMnc = try attributes.decodeIfPresent(String.self, forKey: .currentMnc)
        hardwareEncryptionCaps = try attributes.decode(Int.self, forKey: .hardwareEncryptionCaps)
        passcodePresent = try attributes.decode(Bool.self, forKey: .passcodePresent)
        passcodeCompliant = try attributes.decode(Bool.self, forKey: .passcodeCompliant)
        passcodeCompliantWithProfiles = try attributes.decode(Bool.self, forKey: .passcodeCompliantWithProfiles)
        filevaultEnabled = try attributes.decode(Bool.self, forKey: .filevaultEnabled)
        filevaultRecoveryKey = try attributes.decodeIfPresent(String.self, forKey: .filevaultRecoveryKey)
        firmwarePasswordEnabled = try attributes.decode(Bool.self, forKey: .firmwarePasswordEnabled)
        firmwarePassword = try attributes.decodeIfPresent(String.self, forKey: .firmwarePassword)
        isSupervised = try attributes.decode(Bool.self, forKey: .isSupervised)
        isDepEnrollment = try attributes.decode(Bool.self, forKey: .isDepEnrollment)
        isUserApprovedEnrollment = try attributes.decodeIfPresent(Bool.self, forKey: .isUserApprovedEnrollment)
        isDeviceLocatorServiceEnabled = try attributes.decode(Bool.self, forKey: .isDeviceLocatorServiceEnabled)
        isDoNotDisturbInEffect = try attributes.decode(Bool.self, forKey: .isDoNotDisturbInEffect)
        personalHotspotEnabled = try attributes.decodeIfPresent(Bool.self, forKey: .personalHotspotEnabled)
        itunesStoreAccountIsActive = try attributes.decode(Bool.self, forKey: .itunesStoreAccountIsActive)
        lastCloudBackupDate = try attributes.decodeIfPresent(Date.self, forKey: .lastCloudBackupDate)
        isActivationLockEnabled = try attributes.decode(Bool.self, forKey: .isActivationLockEnabled)
        isCloudBackupEnabled = try attributes.decode(Bool.self, forKey: .isCloudBackupEnabled)
        locationLatitude = try attributes.decodeIfPresent(String.self, forKey: .locationLatitude)
        locationLongitude = try attributes.decodeIfPresent(String.self, forKey: .locationLongitude)
        locationAccuracy = try attributes.decodeIfPresent(Int.self, forKey: .locationAccuracy)
        locationUpdatedAt = try attributes.decodeIfPresent(Date.self, forKey: .locationUpdatedAt)

        let relationships = try payload.nestedContainer(keyedBy: RelationshipKeys.self, forKey: .relationships)
        deviceGroup = try relationships.decode(RelatedToOne<DeviceGroup>.self, forKey: .deviceGroup)
        customAttributes = RelatedToManyNested<Device, CustomAttributeValue>(parentId: id)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "device")
    }
}

// MARK: - Device.CustomAttributeValue

extension Device.CustomAttributeValue: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "custom_attribute_values"
    }
}

extension Device.CustomAttributeValue: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case value
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        value = try attributes.decode(String.self, forKey: .value)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "custom_attribute_value")
    }
}

// MARK: - DeviceGroup

extension DeviceGroup: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "device_groups"
    }
}

extension DeviceGroup: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case name
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "device_group")
    }
}

// MARK: - InstalledApp

extension InstalledApp: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "installed_apps"
    }
}

extension InstalledApp: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case name
        case identifier
        case version
        case shortVersion
        case bundleSize
        case dynamicSize
        case managed
        case discoveredAt
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        id = try payload.decode(Identifier.self, forKey: .id)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        name = try attributes.decode(String.self, forKey: .name)
        identifier = try attributes.decode(String.self, forKey: .identifier)
        version = try attributes.decode(String.self, forKey: .version)
        shortVersion = try attributes.decode(String.self, forKey: .shortVersion)
        bundleSize = try attributes.decode(Int.self, forKey: .bundleSize)
        dynamicSize = try attributes.decode(Int.self, forKey: .dynamicSize)
        managed = try attributes.decode(Bool.self, forKey: .managed)
        discoveredAt = try attributes.decode(Date.self, forKey: .discoveredAt)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "installed_app")
    }
}

// MARK: - PushCertificate
extension PushCertificate: Resource {
    /// The remote API endpoint identifying this resource.
    public static var endpointName: String {
        return "push_certificate"
    }
}

extension PushCertificate: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case attributes
    }

    private enum AttributesKeys: String, CodingKey {
        case appleId
        case expiresAt
    }

    /// Creates a new instance of the resource by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or
    /// otherwise invalid.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let payload = try decoder.container(keyedBy: CodingKeys.self)

        let attributes = try payload.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        appleId = try attributes.decode(String.self, forKey: .appleId)
        expiresAt = try attributes.decode(Date.self, forKey: .expiresAt)

        try decodeAndValidateType(forKey: .type, in: payload, expecting: "push_certificate")
    }
}
