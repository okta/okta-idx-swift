//
//  CredentialCreationData.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/9/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The result of invoking create on the client
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#credentialcreationdata-clientextensionresults)
 */
struct CredentialCreationData {
    let attestationObjectResult: AttestationObject
    let clientDataJSONResult: Data
    let attestationConveyancePreferenceOption: AttestationConveyancePreference
    let clientExtensionResults: AuthenticationExtensionsClientOutputs
}
