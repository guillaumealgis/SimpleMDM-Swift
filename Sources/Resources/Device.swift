//
//  Device.swift
//  SimpleMDM-API
//
//  Created by Guillaume Algis on 22/05/2018.
//  Copyright © 2018 Guillaume Algis. All rights reserved.
//

import Foundation

public struct Device : ListableResource {
    // sourcery:inline:auto:Device.Identifiable
    public let id: Int
    // sourcery:end
    
    let uniqueIdentifier: String
    let serialNumber: String
    let imei: String?
    let meid: String?
    let iccid: String?

    let name: String
    let deviceName: String

    let lastSeenAt: Date
    let status: String

    let modelName: String
    let model: String
    let productName: String

    let osVersion: String
    let buildVersion: String
    let modemFirmwareVersion: String?
    let carrierSettingsVersion: String?

    let deviceCapacity: Double
    let availableDeviceCapacity: Double

    let batteryLevel: String

    let bluetoothMac: String
    let wifiMac: String
    let currentCarrierNetwork: String?
    let simCarrierNetwork: String?
    let subscriberCarrierNetwork: String?

    let phoneNumber: String?
    let cellularTechnology: Int
    let voiceRoamingEnabled: Bool?
    let dataRoamingEnabled: Bool
    let isRoaming: Bool
    let subscriberMcc: String?
    let simmnc: String?
    let currentMcc: String?
    let subscriberMnc: String?
    let simmcc: String?
    let currentMnc: String?

    let hardwareEncryptionCaps: Int
    let passcodePresent: Bool
    let passcodeCompliant: Bool
    let passcodeCompliantWithProfiles: Bool
    let filevaultEnabled: Bool
    let filevaultRecoveryKey: String?
    let firmwarePassword: String?
    let firmwarePasswordEnabled: Bool

    let isSupervised: Bool
    let isDepEnrollment: Bool
    let isUserApprovedEnrollment: Bool?
    let isDeviceLocatorServiceEnabled: Bool
    let isDoNotDisturbInEffect: Bool
    let personalHotspotEnabled: Bool?
    let itunesStoreAccountIsActive: Bool
    let lastCloudBackupDate: Date?
    let isActivationLockEnabled: Bool
    let isCloudBackupEnabled: Bool

    let locationLatitude: String?
    let locationLongitude: String?
    let locationAccuracy: Int?
    let locationUpdatedAt: Date?

    let deviceGroup: RelatedToOne<DeviceGroup>
}

