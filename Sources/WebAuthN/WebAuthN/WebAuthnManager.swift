////
////  WebAuthnManager.swift
////  Okta Verify
////
////  Created by Michael Biviano on 10/19/22.
////  Copyright © 2022 Okta. All rights reserved.
////
//
//import Foundation
//
//protocol WebAuthnManagerProtocol {
//    func authenticate(userID: String, orgURL: URL, factorID: String) async
//    func disenroll(userID: String, orgURL: URL, factorID: String) async
//    func enroll(userID: String, orgURL: URL) async
//}
//
//final class WebAuthnManager {
//    private let webAuthnClient: WebAuthnClient
//    private let webAuthnOktaAPI: WebAuthnOktaAPI
//    
//    init(webAuthnClient: WebAuthnClient, webAuthnOktaAPI: WebAuthnOktaAPI) {
//        self.webAuthnClient = webAuthnClient
//        self.webAuthnOktaAPI = webAuthnOktaAPI
//    }
//}
//
//// MARK: - WebAuthnManagerProtocol
//
//extension WebAuthnManager: WebAuthnManagerProtocol {
//    func authenticate(userID: String, orgURL: URL, factorID: String) async {
//        let response = await webAuthnOktaAPI.challenge(orgURL: orgURL, userID: userID, factorID: factorID)
//
//        switch response {
//        case .failure(let error):
//            print(error)
//        case .success(let challengeResponse):
//            let credentialStorage = KeychainCredentialStorage()
//            let authenticator = PlatformAuthenticator(credentialStorage: credentialStorage)
//            let webAuthnClient = WebAuthnClient(authenticator: authenticator)
//
//            let credentialRequestOptions = CredentialRequestOptions(publicKey: challengeResponse.embedded.challenge)
//            let getResponse = webAuthnClient.get(origin: "https://fido-okta.hioktane.com",
//                                                 options: credentialRequestOptions,
//                                                 sameOriginWithAncestors: true)
//
//            switch getResponse {
//            case .failure(let error):
//                print(error)
//            case .success(let assertionCreationData):
//                let verifyResponse = await webAuthnOktaAPI.verify(
//                    orgURL: orgURL,
//                    userID: userID,
//                    factorID: factorID,
//                    authenticatorData: assertionCreationData.authenticatorDataResult,
//                    clientData: assertionCreationData.clientDataJSONResult,
//                    signatureData: assertionCreationData.signatureResult)
//                print(verifyResponse)
//            }
//        }
//    }
//    
//    func disenroll(userID: String, orgURL: URL, factorID: String) async {
//        let response = await webAuthnOktaAPI.delete(orgURL: orgURL, userID: userID, factorID: factorID)
//        switch response {
//        case .failure(let error):
//            print(error)
//        case .success(let response):
//            print(response)
//        }
//    }
//    
//    func enroll(userID: String, orgURL: URL) async {
//        let response = await webAuthnOktaAPI.enroll(orgURL: orgURL, userID: userID)
//        
//        guard case .success(let enrollResponse) = response else {
//            return
//        }
//        
//        let credentialCreationOptions = CredentialCreationOptions(publicKey: enrollResponse.embedded.activation)
//        let createResponse = webAuthnClient.create(
//            origin: orgURL.absoluteString,
//            options: credentialCreationOptions,
//            sameOriginWithAncestors: true)
//        
//        guard case .success(let credentialCreationData) = createResponse,
//              let attestationBytes = credentialCreationData.attestationObjectResult.toBytes() else {
//            return
//        }
//        
//        _ = await webAuthnOktaAPI.activate(
//            orgURL: orgURL,
//            userID: userID,
//            factorID: enrollResponse.id,
//            attestation: Data(attestationBytes),
//            clientData: credentialCreationData.clientDataJSONResult)
//    }
//}
