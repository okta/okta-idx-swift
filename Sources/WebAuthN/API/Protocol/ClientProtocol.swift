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

public protocol ClientProtocol {
    /**
     [5.1.3] Allows WebAuthn Relying Party scripts to call navigator.credentials.create() to request the creation of a new public key credential source, bound to an authenticator.
     
     - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-createCredential)
     
     - Parameter origin: This argument is the relevant settings object's origin, as determined by the calling create() implementation.
     - Parameter options: This argument is a CredentialCreationOptions object whose options.publicKey member contains a PublicKeyCredentialCreationOptions object specifying the desired attributes of the to-be-created public key credential.
     - Parameter sameOriginWithAncestors: This argument is a Boolean value which is true if and only if the caller’s environment settings object is same-origin with its ancestors. It is false if caller is cross-origin.
     */
    func create(origin: String, options: CredentialCreationOptions, sameOriginWithAncestors: Bool) -> Result<CredentialCreationData, WebAuthnError>
    
    /**
     [5.1.4] Allows WebAuthn Relying Party scripts to call navigator.credentials.create() to request the creation of a new public key credential source, bound to an authenticator.
     
     - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-getAssertion)
     
     - Parameter origin: This argument is the relevant settings object's origin, as determined by the calling create() implementation.
     - Parameter options: This argument is a CredentialRequestOptions object whose options.publicKey member contains a PublicKeyCredentialRequestOptions object specifying the desired attributes of the public key credential to discover.
     - Parameter sameOriginWithAncestors: This argument is a Boolean value which is true if and only if the caller’s environment settings object is same-origin with its ancestors. It is false if caller is cross-origin.
     */
    func get(origin: String, options: CredentialRequestOptions, sameOriginWithAncestors: Bool) -> Result<AssertionCreationData, WebAuthnError>
}
