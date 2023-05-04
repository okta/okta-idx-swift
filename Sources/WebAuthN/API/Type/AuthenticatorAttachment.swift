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
 This enumeration’s values describe authenticators' attachment modalities. Relying Parties use this to express a preferred authenticator attachment modality when calling navigator.credentials.create() to create a credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#enum-attachment)
 */
enum AuthenticatorAttachment: String, Codable {
    case platform
    case crossPlatform = "cross-platform"
}
