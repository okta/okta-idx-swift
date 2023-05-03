//
//  EnrollResponseEmbedded.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/10/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct EnrollResponseEmbedded: Codable {
    let activation: PublicKeyCredentialCreationOptions
}
