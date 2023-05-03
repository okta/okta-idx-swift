//
//  WebAuthnOktaAPI.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/5/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation
import OktaLogger

enum WebAuthnOktaAPIError : Error {
    case apiError
    case noContent
    case invalidJSONResponse
}

protocol WebAuthnOktaAPIProtocol {
    func activate(orgURL: URL, userID: String, factorID: String, attestation: Data, clientData: Data) async -> Result<ActivateFactorResponse, WebAuthnOktaAPIError>
    func challenge(orgURL: URL, userID: String, factorID: String) async -> Result<ChallengeFactorResponse, WebAuthnOktaAPIError>
    func delete(orgURL: URL, userID: String, factorID: String) async -> Result<HTTPStatusCode?, WebAuthnOktaAPIError>
    func enroll(orgURL: URL, userID: String) async -> Result<EnrollFactorResponse, WebAuthnOktaAPIError>
    func verify(orgURL: URL, userID: String, factorID: String, authenticatorData: Data, clientData: Data, signatureData: Data) async -> Result<VerifyFactorResponse, WebAuthnOktaAPIError>
}

final class WebAuthnOktaAPI: WebAuthnOktaAPIProtocol {
    enum Constants {
        static let activatePath = "api/v1/users/%@/factors/%@/lifecycle/activate"
        static let enrollPath = "api/v1/users/%@/factors"
        static let challengePath = "api/v1/users/%@/factors/%@/verify"
        static let deletePath = "api/v1/users/%@/factors/%@"
        static let verifyPath = "api/v1/users/%@/factors/%@/verify"
    }
    
    let httpClient: HttpClientWrapperProtocol
    let logger: OktaLoggerProtocol
    
    init(httpClient: HttpClientWrapperProtocol, logger: OktaLoggerProtocol) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    func activate(orgURL: URL, userID: String, factorID: String, attestation: Data, clientData: Data) async -> Result<ActivateFactorResponse, WebAuthnOktaAPIError> {
        let url = orgURL.appendingPathComponent(String(format: Constants.challengePath, userID, factorID))
        let bodyParameters = ["attestation": attestation.base64EncodedString(), "clientData": clientData.base64EncodedString()]
        return await post(url: url, headers: nil, bodyParameters: bodyParameters)
    }
    
    func challenge(orgURL: URL, userID: String, factorID: String) async -> Result<ChallengeFactorResponse, WebAuthnOktaAPIError> {
        let url = orgURL.appendingPathComponent(String(format: Constants.challengePath, userID, factorID))
        return await post(url: url, headers: nil, bodyParameters: nil)
    }
    
    func delete(orgURL: URL, userID: String, factorID: String) async -> Result<HTTPStatusCode?, WebAuthnOktaAPIError> {
        let url = orgURL.appendingPathComponent(String(format: Constants.deletePath, userID, factorID))
        return await delete(url: url, headers: nil, bodyParameters: nil)
    }
    
    func enroll(orgURL: URL, userID: String) async -> Result<EnrollFactorResponse, WebAuthnOktaAPIError> {
        let url = orgURL.appendingPathComponent(String(format: Constants.enrollPath, userID))
        let bodyParameters = ["factorType": "webauthn", "provider": "FIDO"]
        return await post(url: url, headers: nil, bodyParameters: bodyParameters)
    }
    
    func verify(orgURL: URL, userID: String, factorID: String, authenticatorData: Data, clientData: Data, signatureData: Data) async -> Result<VerifyFactorResponse, WebAuthnOktaAPIError> {
        let url = orgURL.appendingPathComponent(String(format: Constants.challengePath, userID, factorID))
        let bodyParameters = ["authenticatorData": authenticatorData.base64EncodedString(),
                              "clientData": clientData.base64EncodedString(),
                              "signatureData": signatureData.base64EncodedString()]
        return await post(url: url, headers: nil, bodyParameters: bodyParameters)
    }
    
    // MARK: - Private
    
    private func post<T: Codable>(url: URL, headers: [String: String]?, bodyParameters: [String: Any]?) async -> Result<T, WebAuthnOktaAPIError> {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        var allHeaders = headers ?? [:]
        
        let result = await httpClient.httpRequest(
            url,
            method: .POST,
            urlParameters: [:],
            bodyParameters: bodyParameters ?? [:],
            headers: allHeaders)
        
        switch result {
        case .failure(_):
            return .failure(.apiError)
            
        case .success(let response):
            guard let responseBody = response.body else {
                logger.error(eventName: EventNames.webAuthn, message: "Response does not have a body")
                return .failure(.noContent)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let decodedResponse: T
            
            do {
                decodedResponse = try jsonDecoder.decode(T.self, from: responseBody)
            } catch {
                logger.error(eventName: EventNames.webAuthn, message: "Unable to decode response body")
                return .failure(.invalidJSONResponse)
            }

            return .success(decodedResponse)
        }
    }
    
    private func delete(url: URL, headers: [String: String]?, bodyParameters: [String: Any]?) async -> Result<HTTPStatusCode?, WebAuthnOktaAPIError> {
        var allHeaders = headers ?? [:]
        
        let result = await httpClient.httpRequest(
            url,
            method: .DELETE,
            urlParameters: [:],
            bodyParameters: bodyParameters ?? [:],
            headers: allHeaders)
        
        switch result {
        case .failure(_):
            return .failure(.apiError)
            
        case .success(let response):
            return .success(HTTPStatusCode(rawValue: response.statusCode))
        }
    }
}
