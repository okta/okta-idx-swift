/*
 * Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation

/// The IDXClient class is used to define and initiate an authentication workflow utilizing the Okta Identity Engine. Your app can use this to begin a customizable workflow to authenticate and verify the identity of a user using your application.
///
/// The `IDXClient.Configuration` class is used to communicate which application, defined within Okta, the user is being authenticated with. From this point a workflow is initiated, consisting of a series of authentication "Remediation" steps. At each step, your application can introspect the `IDXClient.Response` object to determine which UI should be presented to your user to guide them through to login.
@objc
public final class IDXClient: NSObject {
    
    /// The type used for the completion  handler result from any method that returns an `IDXClient.Response`.
    /// - Parameters:
    ///   - response: The `IDXClient.Response` object that describes the next workflow steps.
    ///   - error: Describes the error that occurred, or `nil` if the request was successful.
    public typealias ResponseResult = (_ response: Response?, _ error: Error?) -> Void
    
    /// The type used for the completion  handler result from any method that returns an `IDXClient.Token`.
    /// - Parameters:
    ///   - token: The `IDXClient.Token` object created when the token is successfully exchanged.
    ///   - error: Describes the error that occurred, or `nil` if the request was successful.
    public typealias TokenResult = (_ token: Token?, _ error: Error?) -> Void

    /// The current context for the authentication session.
    ///
    /// This value will be populated in the following circumstances:
    /// * When a context value is specified when the IDXClient initializer is called.
    /// * When a valid Context object is returned when the `interact` method receives a successful response.
    ///
    /// For convenience, when calls to `introspect` or `exchangeCode` are made with a `nil` context value, they will use the value stored in this `context` property.
    @objc public let context: Context
    
    /// Optional delegate property, used to be informed when important events occur throughout the authentication workflow.
    @objc public weak var delegate: IDXClientDelegate? = nil
    
    /// Starts a new authentication session using the given configuration values. If the client is able to successfully interact with Okta Identity Engine, a new client instance is returned to the caller.
    /// - Parameters:
    ///   - configuration: Configuration describing the app settings to contact.
    ///   - state: Optional state string to use within the OAuth2 transaction.
    ///   - completion: Completion block to be invoked when a client is created, or when an error is received.
    @objc public static func start(with configuration: Configuration,
                                   state: String? = nil,
                                   completion: @escaping (_ client: IDXClient?, _ error: Error?) -> Void)
    {
        let api = Version.latest.clientImplementation(with: configuration)
        api.start(state: state) { (context, error) in
            guard let context = context else {
                completion(nil, error)
                return
            }
            
            let client = IDXClient(context: context, api: api)
            completion(client, nil)
        }
    }
    
    /// Initializes an IDX client instance with the given configuration object.
    /// - Parameters:
    ///   - context: Context object to use when resuming a session.
    @objc public convenience init(context: Context) {
        let api = context.version.clientImplementation(with: context.configuration)
        self.init(context: context, api: api)
    }
        
    /// Resumes the authentication state to identify the available remediation steps.
    ///
    /// Once an interaction handle is received, this method can be used to determine what remedation options are available to the user to authenticate.
    /// - Important:
    /// If a completion handler is not provided, you should ensure that you implement the `IDXClientDelegate.idx(client:didReceive:)` methods to process any response or error returned from this call.
    /// - Parameters:
    ///   - context: `IDXClient.Context` object that contains a valid interactionHandle, or `nil` to use the value in the IDXClient.
    ///   - completion: Optional completion handler invoked when a response is received.
    ///   - response: The response describing the new workflow next steps, or `nil` if an error occurred.
    ///   - error: Describes the error that occurred, or `nil` if successful.
    @objc public func resume(completion: ResponseResult?) {
        api.resume { (response, error) in
            self.handleResponse(response, error: error, completion: completion)
        }
    }
    
    /// Evaluates the given redirect URL.
    /// - Parameters:
    ///   - context: `IDXClient.Context` value returned from `interact`, or `nil` to use the value stored in the IDXClient.
    ///   - url: URL with the app’s custom scheme. The value must match one of the authorized redirect URIs, which are configured in Okta Admin Console.
    /// - Returns: Result of parsing the given redirect URL.
    @objc public func redirectResult(for url: URL) -> RedirectResult {
        api.redirectResult(for: url)
    }
    
    /// Exchanges the redirect URL with a token.
    ///
    /// Once the `redirectResult` method returns `authenticated`, the developer can exchange that redirect URL for a valid token by using this method.
    /// - Important:
    /// If a completion handler is not provided, you should ensure that you implement the `IDXClientDelegate.idx(client:didExchangeToken:)` method to receive the token or to handle any errors.
    /// - Parameters:
    ///   - context: `IDXClient.Context` value returned from `interact`, or `nil` to use the value stored in the IDXClient.
    ///   - url: URL with the app’s custom scheme. The value must match one of the authorized redirect URIs, which are configured in Okta Admin Console.
    ///   - completion: Optional completion handler invoked when a token, or error, is received.
    @objc(exchangeCodeWithRedirectUrl:completion:)
    public func exchangeCode(redirect url: URL,
                             completion: TokenResult?) {
        api.exchangeCode(redirect: url) { (token, error) in
            self.handleResponse(token, error: error, completion: completion)
        }
    }
    
    internal let api: IDXClientAPIImpl
    internal required init(context: Context, api: IDXClientAPIImpl) {
        self.context = context
        self.api = api

        super.init()

        self.api.client = self
    }
    
    @objc(revokeToken:type:completion:)
    public func revoke(token: Token, type: Token.RevokeType, completion: @escaping(_ successful: Bool, _ error: Error?) -> Void) {
        let selectedToken: String?
        switch type {
        case .refreshToken:
            selectedToken = token.refreshToken
        case .accessAndRefreshToken:
            selectedToken = token.accessToken
        }
        
        guard let tokenString = selectedToken else {
            completion(false, IDXClientError.invalidParameter(name: "token"))
            return
        }
        
        revoke(token: tokenString, type: type, completion: completion)
    }

    @objc(revokeTokenWithString:type:completion:)
    public func revoke(token: String, type: Token.RevokeType, completion: @escaping(_ successful: Bool, _ error: Error?) -> Void) {
        api.revoke(token: token, type: type.tokenTypeHint) { (success, error) in
            completion(success, error)
        }
    }
}

/// Delegate protocol that can be used to receive updates from the IDXClient through the process of a user's authentication.
@objc
public protocol IDXClientDelegate {
    /// Message sent when an error is received at any point during the authentication process.
    /// - Parameters:
    ///   - client: IDXClient sending the error.
    ///   - error: The error that was received.
    @objc(idxClient:didReceiveError:)
    func idx(client: IDXClient, didReceive error: Error)
    
//    /// Message sent when an IDX context object is returned from `interact`.
//    /// - Parameters:
//    ///   - client: IDXClient sending the response.
//    ///   - context: The context that was received.
//    @objc(idxClient:didReceiveContext:)
//    func idx(client: IDXClient, didReceive context: IDXClient.Context)
    
    /// Informs the delegate when an IDX response is received, either through an `introspect` or `proceed` call.
    /// - Parameters:
    ///   - client: IDXClient receiving the response.
    ///   - response: The response that was received.
    @objc(idxClient:didReceiveResponse:)
    func idx(client: IDXClient, didReceive response: IDXClient.Response)
    
    /// Informs the delegate when authentication is successful, and the token is returned.
    /// - Parameters:
    ///   - client: IDXClient receiving the token.
    ///   - token: The IDX token object describing the user's credentials.
    @objc(idxClient:didReceiveToken:)
    func idx(client: IDXClient, didReceive token: IDXClient.Token)
}

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
