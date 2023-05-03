//
//  WebAuthnError.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The error names table below lists all the allowed error names for DOMException, a description, and legacy code values.
 
 - Note: [W3C Reccomendation](https://webidl.spec.whatwg.org/#idl-DOMException-error-names)
 */
enum WebAuthnError: Error {
    case constraintError
    case encodingError
    case notAllowedError
    case notSupported
    case securityError
    case typeError
    case unknownError
}
