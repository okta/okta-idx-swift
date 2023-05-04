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
 WebAuthn Relying Parties may use the AuthenticatorSelectionCriteria dictionary to specify their requirements regarding authenticator attributes.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-authenticatorSelection)
 */
public struct AuthenticatorSelectionCriteria: Codable {
    /// If this member is present, eligible authenticators are filtered to only authenticators attached with the specified Authenticator Attachment
    public let authenticatorAttachment: String?
    /// This member is retained for backwards compatibility with WebAuthn Level 1 and, for historical reasons, its naming retains the deprecated “resident” terminology for discoverable credentials
    public let requireResidentKey: Bool
    /// Specifies the extent to which the Relying Party desires to create a client-side discoverable credential.
    public let residentKey: String?
    /// This member describes the Relying Party's requirements regarding user verification for the create() operation.
    public let userVerification: UserVerificationRequirement
}
