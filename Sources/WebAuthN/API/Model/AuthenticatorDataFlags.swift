// Copyright (c) 2023-Present, Okta, Inc. and/or its affiliates. All rights reserved.
// The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and limitations under the License.
//

import Foundation

/**
 The authenticator data structure encodes contextual bindings made by the authenticator.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-authenticator-data)
 */

public struct AuthenticatorDataFlags {

    /// Bit 0: User Present (UP) result.
    ///     1 means the user is present.
    ///     0 means the user is not present.
    let UPMask: UInt8 = 0b00000001
    /// Bit 1: Reserved for future use (RFU1).
    /// Bit 2: User Verified (UV) result.
    ///     1 means the user is verified.
    ///     0 means the user is not verified.
    let UVMask: UInt8 = 0b00000100
    /// Bits 3-5: Reserved for future use (RFU2).
    /// Bit 6: Attested credential data included (AT).
    ///     Indicates whether the authenticator added attested credential data.
    let ATMask: UInt8 = 0b01000000
    /// Bit 7: Extension data included (ED).
    ///     Indicates if the authenticator data has extensions.
    let EDMask: UInt8 = 0b10000000

    var userPresent: Bool = false
    var userVerified: Bool = false
    var hasAttestedCredentialData: Bool = false
    var hasExtension: Bool = false

    init(
        userPresent: Bool,
        userVerified: Bool,
        hasAttestedCredentialData: Bool,
        hasExtension: Bool
    ) {
        self.userPresent = userPresent
        self.userVerified = userVerified
        self.hasAttestedCredentialData = hasAttestedCredentialData
        self.hasExtension  = hasExtension
    }

    init(flags: UInt8) {
        userPresent = ((flags & UPMask) == UPMask)
        userVerified = ((flags & UVMask) == UVMask)
        hasAttestedCredentialData = ((flags & ATMask) == ATMask)
        hasExtension = ((flags & EDMask) == EDMask)
    }

    public func toByte() -> UInt8 {
        var flags: UInt8 = 0b00000000
        if self.userPresent {
            flags = flags | UPMask
        }
        if self.userVerified {
            flags = flags | UVMask
        }
        if self.hasAttestedCredentialData {
            flags = flags | ATMask
        }
        if self.hasExtension {
            flags = flags | EDMask
        }
        return flags
    }
}
