//
//  AuthenticatorProtocol.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

// swiftlint:disable function_parameter_count
protocol AuthenticatorProtocol {
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
                        extensions: SimpleOrderedDictionary<String>) -> Result<AttestationObject, WebAuthnError>
    
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
                      extensions: SimpleOrderedDictionary<String>) -> Result<AssertionObject, WebAuthnError>
}
