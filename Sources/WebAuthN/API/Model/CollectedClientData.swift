//
//  CollectedClientData.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

public struct CollectedClientData : Codable {
    let type: CollectedClientDataType
    let challenge: String
    let origin: String
    let tokenBinding: TokenBinding?
}
