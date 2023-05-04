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
 Authenticators SHOULD also provide some form of attestation, if possible. If an authenticator does, the basic requirement is that the authenticator can produce, for each credential public key, an attestation statement verifiable by the WebAuthn Relying Party. Typically, this attestation statement contains a signature by an attestation private key over the attested credential public key and a challenge, as well as a certificate or similar data providing provenance information for the attestation public key, enabling the Relying Party to make a trust decision.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-attestation)
 */
public struct AttestationObject {
    public let fmt: String
    public let authData: AuthenticatorData
    public let attStmt: OrderedDictionary<String, Any>
    
    public func toBytes() -> [UInt8]? {
        var dict = OrderedDictionary<String, Any>()
        dict["authData"] = authData.toBytes()
        dict["fmt"] = fmt
        dict["attStmt"] = attStmt

        return CBORWriter()
            .putStringKeyMap(dict)
            .getResult()
    }
}
