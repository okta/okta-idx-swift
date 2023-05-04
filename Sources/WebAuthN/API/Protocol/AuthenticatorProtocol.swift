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

// swiftlint:disable function_parameter_count
public protocol AuthenticatorProtocol {
    /**
     Lookup credential source by credential ID
     
     - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-op-lookup-credsource-by-credid)
     */
    
    func lookupCredentialSource(credentialID: [UInt8]) -> PublicKeyCredentialSource?
    
    /**
     Creates the credential
     
     - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-op-make-cred)
     */
    func makeCredential(hash: [UInt8],
                        rpEntity: PublicKeyCredentialRpEntity,
                        userEntity: PublicKeyCredentialUserEntity,
                        requireResidentKey: Bool,
                        requireUserPresence: Bool,
                        requireUserVerification: Bool,
                        credTypesAndPubKeyAlgs:[PublicKeyCredentialParameters],
                        excludeCredentialDescriptorList: [PublicKeyCredentialDescriptor],
                        enterpriseAttestationPossible: Bool,
                        extensions: OrderedDictionary<String, Any>) -> Result<AttestationObject, WebAuthnError>
    
    /**
     Gets assertion
     
     - Parameter rpID: The caller’s RP ID, as determined by the user agent and the client.
     - Parameter hash: The hash of the serialized client data, provided by the client.
     - Parameter allowCredentialDescriptorList: An OPTIONAL list of PublicKeyCredentialDescriptors describing credentials acceptable to the Relying Party (possibly filtered by the client), if any.
     - Parameter requireUserPresence: The constant Boolean value true. It is included here as a pseudo-parameter to simplify applying this abstract authenticator model to implementations that may wish to make a test of user presence optional although WebAuthn does not.
     - Parameter requireUserVerification: The effective user verification requirement for assertion, a Boolean value provided by the client.
     - Parameter extensions: A CBOR map from extension identifiers to their authenticator extension inputs, created by the client based on the extensions requested by the Relying Party, if any.
     
     - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-op-get-assertion)
     */
    func getAssertion(rpID: String,
                      hash: [UInt8],
                      allowCredentialDescriptorList: [PublicKeyCredentialDescriptor]?,
                      requireUserPresence: Bool,
                      requireUserVerification: Bool,
                      extensions: OrderedDictionary<String, Any>) -> Result<AssertionObject, WebAuthnError>
}
