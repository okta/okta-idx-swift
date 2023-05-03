//
//  ChallengeResponseEmbedded.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/11/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct ChallengeResponseEmbedded: Codable {
    let challenge: PublicKeyCredentialRequestOptions
}
