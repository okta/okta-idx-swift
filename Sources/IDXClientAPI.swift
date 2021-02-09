//
//  IDXClientAPI.swift
//  okta-idx-ios
//
//  Created by Mike Nachbaur on 2020-12-09.
//

import Foundation

/// Errors reported from IDXClient
public enum IDXClientError: Error {
    case invalidClient
    case cannotCreateRequest
    case invalidHTTPResponse
    case invalidResponseData
    case invalidRequestData
    case serverError(message: String, localizationKey: String, type: String)
    case internalError(message: String)
    case invalidParameter(name: String)
    case invalidParameterValue(name: String, type: String)
    case parameterImmutable(name: String)
    case missingRequiredParameter(name: String)
    case unknownRemediationOption(name: String)
    case successResponseMissing
}

@objc
public protocol IDXClientAPI {
    /// Performs a request to interact with IDX, based on configured client options.
    /// - Parameters:
    ///   - completion: Invoked when a response, or error, is received.
    ///   - context: An object describing the context of the IDX interaction, or `nil` if the client configuration was invalid.
    ///   - error: Describes the error that occurred, or `nil` if successful.
    @objc func interact(completion: @escaping(_ context: IDXClient.Context?, _ error: Error?) -> Void)
    
    /// Introspects the authentication state to identify the available remediation steps.
    /// - Parameters:
    ///   - interactionHandle: Interaction handle used to introspect the state.
    ///   - completion: Invoked when a response, or error, is received.
    ///   - response: The response describing the next steps available in this workflow.
    ///   - error: Describes the error that occurred, or `nil` if successful.
    @objc func introspect(_ interactionHandle: String,
                          completion: ((_ reponse: IDXClient.Response?, _ error: Error?) -> Void)?)

    /// Indicates whether or not the current stage in the workflow can be cancelled.
    @objc var canCancel: Bool { get }
    
    /// Cancels the current workflow.
    /// - Parameters:
    ///   - completion: Invoked when the operation is cancelled.
    ///   - response: The response describing the new workflow next steps, or `nil` if an error occurred.
    ///   - error: Describes the error that occurred, or `nil` if successful.
    @objc func cancel(completion: ((_ response: IDXClient.Response?, _ error: Error?) -> Void)?)
    
    /// Proceeds to the given remediation option.
    /// - Parameters:
    ///   - option: Remediation option to proceed to.
    ///   - data: Data to supply to the remediation step.
    ///   - completion: Invoked when a response, or error, is received.
    ///   - response: The response describing the next steps available in this workflow.
    ///   - error: Describes the error that occurred, or `nil` if successful.
    @objc func proceed(remediation option: IDXClient.Remediation.Option,
                       data: [String : Any],
                       completion: ((_ response: IDXClient.Response?, _ error: Swift.Error?) -> Void)?)
    
    /// Exchanges the successful response with a token.
    /// - Parameters:
    ///   - response: Successful response.
    ///   - completion: Completion handler invoked when a token, or error, is received.
    ///   - token: The token that was exchanged, or `nil` if an error occurred.
    ///   - error: Describes the error that occurred, or `nil` if successful.
    @objc func exchangeCode(using response: IDXClient.Response,
                            completion: ((_ token: IDXClient.Token?, _ error: Swift.Error?) -> Void)?)
}
