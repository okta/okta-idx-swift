//
//  ActivateResponseProfile.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/10/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct ActivateResponseProfile: Codable {
    let appID: String?
    let authenticatorName: String
    let credentialId: String
    let version: String?
}
