// Copyright (c) 2023-Present, Okta, Inc. and/or its affiliates. All rights reserved.
// The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and limitations under the License.
//

import Foundation
import CryptoKit
import OrderedCollections

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
final class PlatformAuthenticator {
    private let supportedCredTypesAndPubKeyAlgs = [PublicKeyCredentialParameters(alg: .es256, type: .publicKey)]
    private let credentialStorage: CredentialStorageProtocol?
    
    init(credentialStorage: CredentialStorageProtocol?) {
        self.credentialStorage = credentialStorage
    }
    
    private func getSupportedCredTypesAndPubKeyAlg(_ credTypesAndPubKeyAlgs: [PublicKeyCredentialParameters]) -> PublicKeyCredentialParameters? {
        for credTypesAndPubKeyAlg in supportedCredTypesAndPubKeyAlgs {
            if credTypesAndPubKeyAlgs.contains(where: { $0.type == credTypesAndPubKeyAlg.type && $0.alg == credTypesAndPubKeyAlg.alg }) {
                return credTypesAndPubKeyAlg
            }
        }
        return nil
    }
}

 // MARK: - AuthenticatorProtocol

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension PlatformAuthenticator: AuthenticatorProtocol {
    func lookupCredentialSource(credentialID: [UInt8]) -> PublicKeyCredentialSource? {
        
        return nil
    }
    
    // swiftlint:disable function_parameter_count
    func makeCredential(hash: [UInt8],
                        rpEntity: PublicKeyCredentialRpEntity,
                        userEntity: PublicKeyCredentialUserEntity,
                        requireResidentKey: Bool,
                        requireUserPresence: Bool,
                        requireUserVerification: Bool,
                        credTypesAndPubKeyAlgs:[PublicKeyCredentialParameters],
                        excludeCredentialDescriptorList: [PublicKeyCredentialDescriptor],
                        enterpriseAttestationPossible: Bool,
                        extensions: OrderedDictionary<String, Any>) -> Result<AttestationObject, WebAuthnError> {
        
        // [6.3.2.1]
        // All supplied parameters are syntactically well-formed and of the correct length
        
        // [6.3.2.2]
        guard let credTypesAndPubKeyAlg = getSupportedCredTypesAndPubKeyAlg(credTypesAndPubKeyAlgs) else {
            return .failure(.notSupported)
        }
        
        // [6.3.2.3]
        for descriptor in excludeCredentialDescriptorList {
            if let credentialSource = credentialStorage?.lookupCredentialSource(credentialID: descriptor.id),
               credentialSource.type == descriptor.type,
               credentialSource.rpID == rpEntity.id {
                // TODO: Prompt user to see if they want to create a new credential
                return .failure(.notAllowedError)
            }
        }
        
        // [6.3.2.4]
        if requireResidentKey == true && credentialStorage == nil {
            return .failure(.constraintError)
        }
        
        // [6.3.2.5]
        // User verification can be performed
        
        // [6.3.2.6]
        // User verificaation and presence has already been confirmed with creation of LAContext
        
        // [6.3.2.7.1]
        guard let accessControl = SecAccessControlCreateWithFlags(nil,
                                                                  kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                                  [.privateKeyUsage /*, .userPresence*/],
                                                                  nil),
              let privateKey = try? SecureEnclave.P256.Signing.PrivateKey(accessControl: accessControl) else {
            return .failure(.unknownError)
        }
        
        // [6.3.2.7.2]
        let userHandle = userEntity.id
        
        // [6.3.2.7.3]
        let credentialID = Array(UUID().uuidString.utf8)
        let credentialSource = PublicKeyCredentialSource(
            type: .publicKey,
            credentialID: credentialID,
            privateKey: privateKey.rawRepresentation,
            rpID: rpEntity.id,
            userHandle: userHandle,
            otherUI: nil)
        
        // [6.3.2.7.4], [6.3.2.7.5]
        credentialStorage?.deleteCredentialSources(rpID: rpEntity.id)
        credentialStorage?.storeCredentialSource(credentialSource)
        
        // [6.3.2.8]
        // All potential errors handled
        
        // [6.3.2.9]
        let processedExtensions = OrderedDictionary<String, Any>()
        
        // [6.3.2.10]
        let signatureCount: UInt32 = 0
        
        // [6.3.2.11]
        let publicKeyCOSE = privateKey.publicKey.toCOSEKeyEC2(alg: credTypesAndPubKeyAlg.alg, crv: COSEKeyCurveType.p256)
        let attestedCredentialData = AttestedCredentialData(
            aaguid: UUIDHelper.zeroBytes,
            credentialIdLength: UInt16(credentialID.count),
            credentialId: credentialID,
            credentialPublicKey: publicKeyCOSE)
        
        // [6.3.2.12]
        let flags = AuthenticatorDataFlags(
            userPresent: requireUserPresence || requireUserVerification,
            userVerified: requireUserVerification,
            hasAttestedCredentialData: true,
            hasExtension: !processedExtensions.isEmpty)
        
        let authenticatorData = AuthenticatorData(
            rpIdHash: SHA256.hash(data: Array(rpEntity.id.utf8)).bytes,
            flags: flags,
            signCount: signatureCount,
            attestedCredentialData: attestedCredentialData,
            extensions: processedExtensions
        )
        
        // [6.3.2.13]
        var dataToAttest = authenticatorData.toBytes()
        dataToAttest.append(contentsOf: hash)
        guard let signature = try? privateKey.signature(for: dataToAttest) else {
            return .failure(.unknownError)
        }
        
        var attestationStatement = OrderedDictionary<String, Any>()
        attestationStatement["alg"] = Int64(credTypesAndPubKeyAlg.alg.rawValue)
        attestationStatement["sig"] = Array(signature.derRepresentation)
        
        let attestationObject = AttestationObject(fmt: "packed", authData: authenticatorData, attStmt: attestationStatement)
        return .success(attestationObject)
    }
    
    func getAssertion(rpID: String,
                      hash: [UInt8],
                      allowCredentialDescriptorList: [PublicKeyCredentialDescriptor]?,
                      requireUserPresence: Bool,
                      requireUserVerification: Bool,
                      extensions: OrderedDictionary<String, Any>) -> Result<AssertionObject, WebAuthnError> {
        
        // [6.3.3.1]
        // All supplied parameters are syntactically well-formed and of the correct length
        
        // [6.3.3.2]
        var credentialOptions = [PublicKeyCredentialSource]()
        
        // [6.3.3.3]
        if let allowCredentialDescriptors = allowCredentialDescriptorList,
           !allowCredentialDescriptors.isEmpty {
            for descriptor in allowCredentialDescriptors {
                if let credSource = lookupCredentialSource(credentialID: descriptor.id) {
                    credentialOptions.append(credSource)
                }
            }
        } else {
            // [6.3.3.4]
            if let credentialSources = credentialStorage?.lookupCredentialSources(rpID: rpID) {
                credentialOptions.append(contentsOf: credentialSources)
            }
        }
        
        // [6.3.3.5]
        credentialOptions = credentialOptions.filter { $0.rpID == rpID }
        
        // [6.3.3.6]
        if credentialOptions.isEmpty {
            return .failure(.notAllowedError)
        }
        
        // [6.3.3.7]
        // TODO: Prompt user to choose credential if more than one avialble
        let selectedCredential = credentialOptions.first!
        
        // [6.3.3.8]
        let processedExtensions = OrderedDictionary<String, Any>()
        
        // [6.3.3.9]
        var signatureCount = credentialStorage?.lookupCredentialSourceSignCount(credentialID: selectedCredential.credentialID) ?? 0
        signatureCount += 1
        
        // [6.3.3.10]
        let flags = AuthenticatorDataFlags(
            userPresent: requireUserPresence || requireUserVerification,
            userVerified: requireUserVerification,
            hasAttestedCredentialData: true,
            hasExtension: !processedExtensions.isEmpty)
        
        let authenticatorData = AuthenticatorData(
            rpIdHash: SHA256.hash(data: Array(rpID.utf8)).bytes,
            flags: flags,
            signCount: signatureCount,
            attestedCredentialData: nil,
            extensions: processedExtensions
        )
        
        // [6.3.3.11]
        var dataToAttest = authenticatorData.toBytes()
        dataToAttest.append(contentsOf: hash)
        guard let privateKey = try? SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: selectedCredential.privateKey),
              let signature = try? privateKey.signature(for: dataToAttest) else {
            return .failure(.unknownError)
        }
        
        // [6.3.3.12]
        // All potential errors handled
        
        // [6.3.3.13]
        // TODO: Only return credential if necessary
        // let credentialID = (allowCredentialDescriptorList?.count ?? 0) > 1 ? selectedCredential.credentialID : nil
        let assertionObject = AssertionObject(credentialID: selectedCredential.credentialID,
                                              userHandle: selectedCredential.userHandle,
                                              authenticatorData: authenticatorData,
                                              signature: signature.derRepresentation)
        
        return .success(assertionObject)
    }
}
