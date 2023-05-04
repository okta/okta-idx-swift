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
 A credential source used by an authenticator to generate authentication assertions.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#public-key-credential-source)
 */
public struct PublicKeyCredentialSource {
    /// Credential type
    public let type: PublicKeyCredentialType
    /// A Credential ID.
    public let credentialID: [UInt8]
    /// The credential private key.
    public let privateKey: Data
    /// The Relying Party Identifier, for the Relying Party this public key credential source is scoped to.
    public let rpID: String
    /// The user handle associated when this public key credential source was created. This item is nullable.
    public let userHandle: [UInt8]
    /// OPTIONAL other information used by the authenticator to inform its UI. For example, this might include the user’s displayName. otherUI is a mutable item and SHOULD NOT be bound to the public key credential source in a way that prevents otherUI from being updated.
    public let otherUI: String?
}
