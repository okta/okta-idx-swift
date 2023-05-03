//
//  KeychainCredentialStorage.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation
import CryptoKit

// MARK: - Storage conversion

protocol GenericPasswordConvertible: CustomStringConvertible {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
    var rawRepresentation: Data { get }
}

extension GenericPasswordConvertible {
    public var description: String {
        return self.rawRepresentation.withUnsafeBytes { bytes in
            return "Key representation contains \(bytes.count) bytes."
        }
    }
}

extension SecureEnclave.P256.Signing.PrivateKey: GenericPasswordConvertible {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data.dataRepresentation)
    }
    
    var rawRepresentation: Data {
        return dataRepresentation
    }
}

extension ContiguousBytes {
    var dataRepresentation: Data {
        return self.withUnsafeBytes { bytes in
            let cfdata = CFDataCreateWithBytesNoCopy(nil, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count, kCFAllocatorNull)
            return ((cfdata as NSData?) as Data?) ?? Data()
        }
    }
}

// MARK: - KeychainCredentialStorage

final class KeychainCredentialStorage {

}

// MARK: - CredentialStorageProtocol

extension KeychainCredentialStorage: CredentialStorageProtocol {
    func deleteCredentialSources(rpID: String) -> Bool {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: rpID] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess ? true : false
    }
    
    func lookupCredentialSource(credentialID: [UInt8]) -> PublicKeyCredentialSource? {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: credentialID,
                     kSecUseDataProtectionKeychain: true,
                     kSecReturnAttributes: true,
                     kSecReturnData: true] as [String: Any]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let existingItem = item,
              let key = existingItem[kSecValueData as String] as? Data,
              let service = existingItem[kSecAttrService as String] as? String,
              let account = existingItem[kSecAttrAccount as String] as? String else {
            return nil
        }
        
        let otherUI = existingItem[kSecAttrDescription as String] as? String ?? nil
        
        return PublicKeyCredentialSource(type: .publicKey,
                                         credentialID: credentialID,
                                         privateKey: key,
                                         rpID: service,
                                         userHandle: Array(account.utf8),
                                         otherUI: otherUI)
    }
    
    func lookupCredentialSources(rpID: String) -> [PublicKeyCredentialSource] {
        var credentialSources = [PublicKeyCredentialSource]()
        
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: rpID,
                     kSecUseDataProtectionKeychain: true,
                     kSecReturnAttributes: true,
                     kSecReturnData: true,
                     kSecMatchLimit: kSecMatchLimitAll] as [String: Any]
        
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        
        guard status == errSecSuccess,
              let existingItems = items as? [[String: Any]] else {
            return credentialSources
        }
        
        for existingItem in existingItems {
            guard let key = existingItem[kSecValueData as String] as? Data,
                  let credentialID = existingItem[kSecAttrLabel as String] as? String,
                  let service = existingItem[kSecAttrService as String] as? String,
                  let account = existingItem[kSecAttrAccount as String] as? String else {
                continue
            }
            
            let otherUI = existingItem[kSecAttrDescription as String] as? String ?? nil
            
            let credenitalSource = PublicKeyCredentialSource(
                type: .publicKey,
                credentialID: Array(credentialID.utf8),
                privateKey: key,
                rpID: service,
                userHandle: Array(account.utf8),
                otherUI: otherUI)
            
            credentialSources.append(credenitalSource)
        }
        
        return credentialSources
    }
    
    func lookupCredentialSourceSignCount(credentialID: [UInt8]) -> UInt32? {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrLabel: credentialID,
                     kSecUseDataProtectionKeychain: true,
                     kSecReturnAttributes: true,
                     kSecReturnData: false] as [String: Any]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let existingItem = item,
              let signCountData = existingItem[kSecAttrGeneric as String] as? Data,
              let signCountString = String(data: signCountData, encoding: .utf8),
              let signCount = UInt32(signCountString) else {
            return nil
        }
        
        return signCount
    }
    
    func storeCredentialSource(_ publicKeyCredentialSource: PublicKeyCredentialSource) -> Bool {
        guard let label = String(bytes: publicKeyCredentialSource.credentialID, encoding: .utf8),
              let account = String(bytes: publicKeyCredentialSource.userHandle, encoding: .utf8) else {
            return false
        }
        
        let valueData = publicKeyCredentialSource.privateKey
        let service = publicKeyCredentialSource.rpID
        
        var query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: service,
                     kSecAttrAccount: account,
                     kSecAttrLabel: label,
                     kSecAttrSynchronizable: false,
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true,
                     kSecValueData: valueData] as [String: Any]
        
        if let otherUI = publicKeyCredentialSource.otherUI {
            query[kSecAttrDescription as String] = otherUI
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess ? true : false
    }
}
