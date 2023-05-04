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
import OrderedCollections

/**
 The authenticator data structure encodes contextual bindings made by the authenticator.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-authenticator-data)
 */
public struct AuthenticatorData {
    
    /// SHA-256 hash of the RP ID the credential is scoped to.
    public let rpIdHash: [UInt8]
    /// Flags (bit 0 is the least significant bit):
    public let flags: AuthenticatorDataFlags
    /// Signature counter, 32-bit unsigned big-endian integer.
    public let signCount: UInt32
    /// Attested credential data (if present)
    public let attestedCredentialData: AttestedCredentialData?
    /// Extension-defined authenticator data.
    public let extensions: OrderedDictionary<String, Any>
    
    public func toBytes() -> [UInt8] {
        if self.rpIdHash.count != 32 {
            fatalError("<AuthenticatorData> rpIdHash should be 32 bytes")
        }

        var result = rpIdHash
        result.append(flags.toByte())

        result.append(UInt8((signCount & 0xff000000) >> 24))
        result.append(UInt8((signCount & 0x00ff0000) >> 16))
        result.append(UInt8((signCount & 0x0000ff00) >>  8))
        result.append(UInt8((signCount & 0x000000ff)))

        if let attestedData = attestedCredentialData {
            result.append(contentsOf: attestedData.toBytes())
        }

        if !extensions.isEmpty {
            let builder = CBORWriter()
            _ = builder.putStringKeyMap(extensions)
            result.append(contentsOf: builder.getResult())
        }

        return result
    }
}
