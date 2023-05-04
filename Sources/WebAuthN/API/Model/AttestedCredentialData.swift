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
 Attested credential data is a variable-length byte array added to the authenticator data when generating an attestation object for a given credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-attested-credential-data)
 */
public struct AttestedCredentialData {
    /// The AAGUID of the authenticator.
    let aaguid: [UInt8]
    /// Byte length L of Credential ID, 16-bit unsigned big-endian integer.
    let credentialIdLength: UInt16
    /// Credential ID
    let credentialId: [UInt8]
    /// The credential public key encoded in COSE_Key format
    let credentialPublicKey: COSEKey

    public func toBytes() -> [UInt8] {
        if self.aaguid.count != 16 {
           fatalError("<AttestedCredentialData> invalid aaguid length")
        }
        var result = aaguid
        result.append(UInt8((credentialIdLength & 0xff00) >> 8))
        result.append(UInt8((credentialIdLength & 0x00ff)))
        result.append(contentsOf: credentialId)
        result.append(contentsOf: credentialPublicKey.toBytes())
        return result
    }
}
