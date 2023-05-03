//
//  AuthenticatorTransport.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 This member contains the type of the public key credential the caller is referring to.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dom-publickeycredentialdescriptor-type)
 */
enum AuthenticatorTransport: String, Codable {
    /// Indicates the respective authenticator can be contacted over Bluetooth Smart (Bluetooth Low Energy / BLE).
    case ble
    /// Indicates the respective authenticator can be contacted over Near Field Communication (NFC).
    case nfc
    /// Indicates the respective authenticator is contacted using a client device-specific transport, i.e., it is a platform authenticator. These authenticators are not removable from the client device.
    case platform = "internal"
    /// Indicates the respective authenticator can be contacted over removable USB
    case usb
}
