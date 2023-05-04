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
public final class WebAuthnClient {
    private let authenticator: AuthenticatorProtocol
    
    public convenience init() {
        self.init(authenticator: PlatformAuthenticator(credentialStorage: KeychainCredentialStorage()))
    }
    
    init(authenticator: AuthenticatorProtocol) {
        self.authenticator = authenticator
    }
}

// MARK: - ClientProtocol

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension WebAuthnClient: ClientProtocol {
    private enum Constants {
        /**
         Recommended ranges and defaults for the timeout member of options when user verification is discouraged
         
         Recommended range: 30000 milliseconds to 180000 milliseconds.
         Recommended default value: 120000 milliseconds (2 minutes).
         
         - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-createCredential)
         */
        static let timeoutInMsForDiscouragedUserVierification: UInt64 = 120000
        /**
         Recommended ranges and defaults for the timeout member of options when user verification is preferred or required
         
         Recommended range: 30000 milliseconds to 600000 milliseconds.
         Recommended default value: 300000 milliseconds (5 minutes).
         
         - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-createCredential)
         */
        static let timeoutInMsForPreferredOrRequiredUserVierification: UInt64 = 300000
    }
    
    // swiftlint:disable cyclomatic_complexity
    public func create(origin: String, options: CredentialCreationOptions, sameOriginWithAncestors: Bool) -> Result<CredentialCreationData, WebAuthnError> {
        // [5.1.3.1]
        // options.publicKey is a non-optional value
        
        // [5.1.3.2]
        guard sameOriginWithAncestors else {
            return .failure(.notAllowedError)
        }
        
        // [5.1.3.3]
        var options = options.publicKey
        
        // [5.1.3.4]
        var timeout = options.timeout
        if timeout == nil {
            switch options.authenticatorSelection.userVerification {
            case .discouraged:
                timeout = Constants.timeoutInMsForDiscouragedUserVierification
            case .preferred, .required:
                timeout = Constants.timeoutInMsForPreferredOrRequiredUserVierification
            }
        }
        
        // [5.1.3.5]
        guard options.user.id.count < 64 else {
            return .failure(.typeError)
        }
        
        // [5.1.3.6]
        let callerOrigin = origin
        
        // [5.1.3.7]
        guard let originURL = URL(string: origin),
              let effectiveDomain = originURL.host else {
            return .failure(.notAllowedError)
        }
        
        // [5.1.3.8]
        if options.rp.id != effectiveDomain && !effectiveDomain.hasPrefix("\(options.rp.id)."){
            return .failure(.securityError)
        } else {
            options.rp.id = effectiveDomain
        }
        
        // [5.1.3.9]
        var credTypesAndPubKeyAlgs: [PublicKeyCredentialParameters]
        
        // [5.1.3.10]
        if options.pubKeyCredParams.isEmpty {
            credTypesAndPubKeyAlgs = [PublicKeyCredentialParameters(alg: .es256, type: .publicKey),
                                      PublicKeyCredentialParameters(alg: .rs256, type: .publicKey)]
        } else {
            credTypesAndPubKeyAlgs = options.pubKeyCredParams.filter { $0.type == .publicKey }
        }
        
        guard !credTypesAndPubKeyAlgs.isEmpty else {
            return .failure(.notSupported)
        }
        
        // [5.1.3.11]
        // Extensions are currently not supported
        // let clientExtensions = SimpleOrderedDictionary<String>()
        let authenticatorExtensions = OrderedDictionary<String, Any>()
        
        // [5.1.3.12]
        // Extensions currently not supported
        
        // [5.1.3.13]
        let collectedClientData = CollectedClientData(
            type: .create,
            challenge: String(bytes: options.challenge, encoding: .utf8)!, // Base64.encodeBase64URL(options.challenge),
            origin: callerOrigin,
            tokenBinding: nil)
        
        // [5.1.3.14]
        guard let clientDataJSONData = try? JSONEncoder().encode(collectedClientData) else {
            return .failure(.encodingError)
        }
        
        // [5.1.3.15]
        let clientDataHash = SHA256.hash(data: clientDataJSONData).bytes
        
        // Create credential
        let result = authenticator.makeCredential(
            hash: clientDataHash,
            rpEntity: options.rp,
            userEntity: options.user,
            requireResidentKey: options.authenticatorSelection.requireResidentKey,
            requireUserPresence: true,
            requireUserVerification: options.authenticatorSelection.userVerification != .discouraged,
            credTypesAndPubKeyAlgs: credTypesAndPubKeyAlgs,
            excludeCredentialDescriptorList: options.excludeCredentials,
            enterpriseAttestationPossible: false,
            extensions: authenticatorExtensions)
        
        switch result {
        case .failure(let error):
            return .failure(error)
        case .success(let attestationObject):
            return .success(CredentialCreationData(
                attestationObjectResult: attestationObject,
                clientDataJSONResult: clientDataJSONData,
                attestationConveyancePreferenceOption: options.attestation,
                clientExtensionResults: AuthenticationExtensionsClientOutputs()))
        }
    }
    
    public func get(origin: String, options: CredentialRequestOptions, sameOriginWithAncestors: Bool) -> Result<AssertionCreationData, WebAuthnError> {
        // [5.1.4.1]
        // options.publicKey is a non-optional value
        
        // [5.1.4.2]
        let options = options.publicKey
        
        // [5.1.4.3]
        var timeout = options.timeout
        if timeout == nil {
            switch options.userVerification {
            case .discouraged:
                timeout = Constants.timeoutInMsForDiscouragedUserVierification
            case .none, .preferred, .required:
                timeout = Constants.timeoutInMsForPreferredOrRequiredUserVierification
            }
        }
        
        // [5.1.4.4]
        let callerOrigin = origin
        
        // [5.1.4.5]
        guard let originURL = URL(string: origin),
              let effectiveDomain = originURL.host else {
            return .failure(.notAllowedError)
        }
        
        // [5.1.4.6]
        let rpID: String
        if let optionsRpID = options.rpID {
            guard optionsRpID == effectiveDomain else {
                return .failure(.securityError)
            }
            rpID = optionsRpID
        } else {
            rpID = effectiveDomain
        }
        
        // [5.1.4.7]
        // Extensions are currently not supported
        // let clientExtensions = SimpleOrderedDictionary<String>()
        let authenticatorExtensions = OrderedDictionary<String, Any>()
        
        // [5.1.4.8]
        // Extensions are currently not supported
        
        // [5.1.4.9]
        let collectedClientData = CollectedClientData(
            type: .get,
            challenge: String(bytes: options.challenge, encoding: .utf8)!, // Base64.encodeBase64URL(options.challenge),
            origin: callerOrigin,
            tokenBinding: nil)
        
        // [5.1.4.10]
        guard let clientDataJSONData = try? JSONEncoder().encode(collectedClientData) else {
            return .failure(.encodingError)
        }
        
        // [5.1.4.11]
        let clientDataHash = SHA256.hash(data: clientDataJSONData).bytes
        
        // Get assertion
        let result = authenticator.getAssertion(
            rpID: rpID,
            hash: clientDataHash,
            allowCredentialDescriptorList: options.allowCredentials,
            requireUserPresence: true,
            requireUserVerification: options.userVerification != .discouraged,
            extensions: authenticatorExtensions)
        
        switch result {
        case .failure(let error):
            return .failure(error)
        case .success(let assertionObject):
            return .success(AssertionCreationData(
                credentialIDResult: assertionObject.credentialID,
                clientDataJSONResult: clientDataJSONData,
                authenticatorDataResult: Data(assertionObject.authenticatorData.toBytes()),
                signatureResult: assertionObject.signature,
                userHandleResult: assertionObject.userHandle,
                clientExtensionResults: AuthenticationExtensionsClientOutputs()))
        }
    }
}
