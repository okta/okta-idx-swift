//
//  AuthenticatorSelectionCriteria.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 WebAuthn Relying Parties may use the AuthenticatorSelectionCriteria dictionary to specify their requirements regarding authenticator attributes.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-authenticatorSelection)
 */
struct AuthenticatorSelectionCriteria: Codable {
    /// If this member is present, eligible authenticators are filtered to only authenticators attached with the specified Authenticator Attachment
    let authenticatorAttachment: String?
    /// This member is retained for backwards compatibility with WebAuthn Level 1 and, for historical reasons, its naming retains the deprecated “resident” terminology for discoverable credentials
    let requireResidentKey: Bool
    /// Specifies the extent to which the Relying Party desires to create a client-side discoverable credential.
    let residentKey: String?
    /// This member describes the Relying Party's requirements regarding user verification for the create() operation.
    let userVerification: UserVerificationRequirement
}
