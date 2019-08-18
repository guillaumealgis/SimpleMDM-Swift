//
//  Copyright 2019 Guillaume Algis.
//  Licensed under the MIT License. See the LICENSE.md file in the project root for more information.
//

import Foundation

/// A device registered in your SimpleMDM account.
public struct Device: ListableResource, SearchableResource {
    // sourcery:inline:auto:Device.Identifiable
    /// The unique identifier of this resource.
    public let id: Int
    // sourcery:end

    // MARK: - Identifiers

    /// An unique 40 characters long hash identifying the device.
    public let uniqueIdentifier: String
    /// The serial number of the device.
    public let serialNumber: String
    /// The [International Mobile Equipment Identity
    /// (IMEI)](https://en.wikipedia.org/wiki/International_Mobile_Equipment_Identity) number of the device.
    public let imei: String?
    /// The [Mobile Equipment IDentifier (MEID)](https://en.wikipedia.org/wiki/Mobile_equipment_identifier) number of
    /// the device.
    public let meid: String?
    /// The [Integrated Circuit Card IDentifier
    /// (ICCID)](https://en.wikipedia.org/wiki/Subscriber_identity_module#ICCID) number of the device.
    public let iccid: String?

    // MARK: - Name

    /// The name you've given to the device in the SimpleMDM interface.
    public let name: String
    /// The name set in the device's settings.
    public let deviceName: String

    // MARK: - Current status

    /// Date at which the device last communicated with SimpleMDM.
    public let lastSeenAt: Date
    /// The current MDM status of the device (e.g. "enrolled").
    public let status: String

    // MARK: - Model

    /// The displayable model name of the device (e.g. "iPad 9.7-Inch 6th Gen").
    public let modelName: String
    /// The Apple model identifier of the device (e.g. "MR7F2NF").
    public let model: String
    /// The Apple product name of the device (e.g. "iPad7,5").
    public let productName: String

    // MARK: - Sofware version

    /// The displayabled current OS version of the device (e.g. "12.0.1").
    public let osVersion: Version
    /// The current build version of the OS (e.g. "16A404").
    public let buildVersion: String
    /// The current modem firmware version of the device (e.g. "6.60.00").
    public let modemFirmwareVersion: String?
    /// The current version of the settings of the cell carrier (e.g. "33.0").
    public let carrierSettingsVersion: String?

    // MARK: - Capacity

    /// The total device storage capacity, in GB.
    public let deviceCapacity: Double
    /// The available device storage capacity, in GB.
    public let availableDeviceCapacity: Double

    // MARK: - Battery

    /// The curreny battery level of the device, in percent (e.g. "76%").
    public let batteryLevel: String?

    // MARK: - Wireless networking

    /// The bluetooth MAC address of the device.
    public let bluetoothMac: String
    /// The wifi MAC address of the device.
    public let wifiMac: String
    /// The current carrier network of the device.
    public let currentCarrierNetwork: String?
    /// The SIM carrier network of the device.
    public let simCarrierNetwork: String?
    /// The subscriber carrier network of the device.
    public let subscriberCarrierNetwork: String?

    // MARK: - Cellular

    /// The phone number
    public let phoneNumber: String?
    /// The cellular technology of the device. Signification of the value isn't documented by SimpleMDM.
    public let cellularTechnology: Int?
    /// Weither the device allows roaming for voice.
    public let voiceRoamingEnabled: Bool?
    /// Weither the device allows roaming for data.
    public let dataRoamingEnabled: Bool?
    /// Weither the device is currently roaming.
    public let isRoaming: Bool?

    // MARK: - MCC & MNC

    /// The subscriber [Mobile Contry Code (MCC)](https://en.wikipedia.org/wiki/Mobile_country_code) of the device.
    public let subscriberMcc: String?
    /// The subscriber [Mobile Network Code (MNC)](https://en.wikipedia.org/wiki/Mobile_country_code) of the device.
    public let subscriberMnc: String?
    /// The SIM [Mobile Contry Code (MCC)](https://en.wikipedia.org/wiki/Mobile_country_code) of the device.
    public let simmcc: String?
    /// The SIM [Mobile Network Code (MNC)](https://en.wikipedia.org/wiki/Mobile_country_code) of the device.
    public let simmnc: String?
    /// The current [Mobile Contry Code (MCC)](https://en.wikipedia.org/wiki/Mobile_country_code) of the device.
    public let currentMcc: String?
    /// The current [Mobile Network Code (MNC)](https://en.wikipedia.org/wiki/Mobile_country_code) of the device.
    public let currentMnc: String?

    // MARK: - Security

    /// Not documented by SimpleMDM.
    public let hardwareEncryptionCaps: Int?
    /// Weither the device is passcode protected.
    public let passcodePresent: Bool?
    /// Weither the device's passcode is compliant with your global passcode policy.
    public let passcodeCompliant: Bool?
    /// Weither the device's passcode is compliant with the passcode policy defined in your profiles.
    public let passcodeCompliantWithProfiles: Bool?
    /// Weither Filevault (disk encryption) is enabled on the device (macOS only).
    public let filevaultEnabled: Bool
    /// The Filevault recovery key (macOS only).
    public let filevaultRecoveryKey: String?
    /// Weither the firmware of the device is password protected (macOS only?).
    public let firmwarePasswordEnabled: Bool
    /// The firmware password (macOS only?).
    public let firmwarePassword: String?

    // MARK: - MDM

    /// Weither the device is supervised.
    public let isSupervised: Bool?
    /// Weither the device is enrolled in Apple's Device Enrollment Program (DEP).
    public let isDepEnrollment: Bool
    /// Weither the device can be enrolled by the user (?).
    public let isUserApprovedEnrollment: Bool?
    /// Weither the device locator service (Find my Mac / Find my iPhone) is enabled.
    public let isDeviceLocatorServiceEnabled: Bool?
    /// Weither the device is currently in Do Not Disturb mode.
    public let isDoNotDisturbInEffect: Bool?
    /// Weither the device's personal hotspot functionnality is enabled.
    public let personalHotspotEnabled: Bool?
    /// Weither the device's iTunes Store account is active.
    public let itunesStoreAccountIsActive: Bool?
    /// The date of the last iCloud backup of the device.
    public let lastCloudBackupDate: Date?
    /// Weither Activation Lock is enabled on the device.
    public let isActivationLockEnabled: Bool
    /// Weither backing up to iCloud is enabled.
    public let isCloudBackupEnabled: Bool

    // MARK: - Location

    /// The latitude of the device's location (in degrees, e.g. "46.23451120895299").
    public let locationLatitude: String?
    /// The longitude of the device's location (in degrees, e.g. "4.273176170426797").
    public let locationLongitude: String?
    /// The accuracy of the device's location.
    public let locationAccuracy: Int?
    /// The date at which the device's location has been udpated last.
    public let locationUpdatedAt: Date?

    // MARK: - Relations

    /// The groups the devices is a member of.
    public let deviceGroup: RelatedToOne<DeviceGroup>
    /// The custom attributes values set for this device.
    public let customAttributes: RelatedToManyNested<Device, CustomAttributeValue>
}
