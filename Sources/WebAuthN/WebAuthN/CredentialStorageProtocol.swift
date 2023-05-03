//
//  CredentialStorageProtocol.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

protocol CredentialStorageProtocol {
    func deleteCredentialSources(rpID: String) -> Bool
    func lookupCredentialSource(credentialID: [UInt8]) -> PublicKeyCredentialSource?
    func lookupCredentialSources(rpID: String) -> [PublicKeyCredentialSource]
    func lookupCredentialSourceSignCount(credentialID: [UInt8]) -> UInt32?
    func storeCredentialSource(_ publicKeyCredentialSource: PublicKeyCredentialSource) -> Bool
}
