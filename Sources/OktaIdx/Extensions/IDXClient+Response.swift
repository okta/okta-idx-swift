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

public extension IDXClient {
    /// Object that defines the context for the current authentication session, which is required when a session needs to be resumed.
    @objc(IDXContext)
    final class Context: NSObject, Codable {
        /// The interaction handle returned from the `interact` response from the server.
        @objc public let interactionHandle: String
        
        /// The PKCE code verifier value used when initiating the session using the `interact` method.
        @objc public let codeVerifier: String

        internal init(interactionHandle: String,
                      codeVerifier: String)
        {
            self.interactionHandle = interactionHandle
            self.codeVerifier = codeVerifier
        }
    }
    
    /// Describes the response from an Okta Identity Engine workflow stage. This is used to determine the current state of the workflow, the set of available remediation steps to proceed through the workflow, actions that can be performed, and other information relevant to the authentication of a user.
    @objc(IDXResponse)
    final class Response: NSObject {
        private let api: IDXClientAPIImpl
        
        /// The current state handle for the IDX workflow.
        @objc public let stateHandle: String
        
        /// The API version used.
        @objc public let version: String
        
        /// The date at which this stage of the workflow expires, after which the authentication process should be restarted.
        @objc public let expiresAt: Date
        
        /// A string describing the intent of the workflow, e.g. "LOGIN".
        @objc public let intent: String
        
        /// An object describing the sort of remediation steps available to the user, or `nil` if the workflow is ended.
        @objc public let remediation: Remediation?
        
        /// Returns information about the application, if available.
        @objc public let app: Application?
        
        /// Returns information about the user authenticating, if available.
        @objc public let user: User?
        
        /// Contains information about the available authenticators, if available.
        @objc public let authenticators: [Authenticator]?
        
        /// Contains information about the authenticators that have been enrolled, if applicable.
        @objc public let authenticatorEnrollments: [Authenticator.Enrollment]?
        
        /// Contains informatino about the authenticator enrollment that is currently being enrolled.
        @objc public let currentAuthenticatorEnrollment: Authenticator.Enrollment.Current?

        /// The list of messages sent from the server, or `nil` if no messages are available at the response level.
        ///
        /// Messages reported from the server are usually errors, but may include other information relevant to the user. They should be displayed to the user in the context of the remediation form itself.
        @objc public let messages: [Message]?

        /// Indicates whether or not the user has logged in successfully. If this is `true`, this response object should be exchanged for access tokens utilizing the `exchangeCode` method.
        @objc public var isLoginSuccessful: Bool {
            return successResponse != nil
        }
        
        /// Indicates whether or not the response can be cancelled.
        @objc public let canCancel: Bool
        
        /// Cancels the current workflow, and restats the session.
        /// 
        /// - Important:
        /// If a completion handler is not provided, you should ensure that you implement the `IDXClientDelegate.idx(client:didReceive:)` methods to process any response or error returned from this call.
        /// - Parameters:
        ///   - completion: Optional completion handler invoked when the operation is cancelled.
        ///   - response: The response describing the new workflow next steps, or `nil` if an error occurred.
        ///   - error: Describes the error that occurred, or `nil` if successful.
        @objc public func cancel(completion: ((_ response: Response?, _ error: Error?) -> Void)?) {
            guard let cancelOption = cancelRemediationOption else {
                completion?(nil, IDXClientError.unknownRemediationOption(name: "cancel"))
                return
            }
            
            cancelOption.proceed(with: [:], completion: completion)
        }
        
        /// Exchanges the successful response with a token.
        ///
        /// Once the `isLoginSuccessful` property is `true`, the developer can exchange the response for a valid token by using this method.
        /// - Important:
        /// If a completion handler is not provided, you should ensure that you implement the `IDXClientDelegate.idx(client:didExchangeToken:)` method to receive the token or to handle any errors.
        /// - Parameters:
        ///   - context: Context object returned from the initial response to `interact`, or `nil` to use the value stored in the IDXClient.
        ///   - response: Successful response.
        ///   - completion: Optional completion handler invoked when a token, or error, is received.
        ///   - token: The token that was exchanged, or `nil` if an error occurred.
        ///   - error: Describes the error that occurred, or `nil` if successful.
        @objc public func exchangeCode(with context: Context? = nil, completion: ((_ token: Token?, _ error: Error?) -> Void)?) {
            guard let client = api.client else {
                completion?(nil, IDXClientError.invalidClient)
                return
            }
            
            client.exchangeCode(with: context, using: self, completion: completion)
        }
        
        internal let cancelRemediationOption: Remediation.Option?
        internal let successResponse: Remediation.Option?
        internal init(api: IDXClientAPIImpl,
                      stateHandle: String,
                      version: String,
                      expiresAt: Date,
                      intent: String,
                      authenticators: [Authenticator]?,
                      authenticatorEnrollments: [Authenticator.Enrollment]?,
                      currentAuthenticatorEnrollment: Authenticator.Enrollment.Current?,
                      remediation: Remediation?,
                      cancel: Remediation.Option?,
                      success: Remediation.Option?,
                      messages: [Message]?,
                      app: Application?,
                      user: User?)
        {
            self.api = api
            self.stateHandle = stateHandle
            self.version = version
            self.expiresAt = expiresAt
            self.intent = intent
            self.authenticators = authenticators
            self.authenticatorEnrollments = authenticatorEnrollments
            self.currentAuthenticatorEnrollment = currentAuthenticatorEnrollment
            self.remediation = remediation
            self.cancelRemediationOption = cancel
            self.successResponse = success
            self.messages = messages
            self.app = app
            self.user = user
            self.canCancel = (cancel != nil)
            
            super.init()
        }
    }
    
    /// Access tokens created as a result of exchanging a successful workflow response.
    @objc(IDXToken)
    final class Token: NSObject, Codable {
        /// The access token to use.
        @objc public let accessToken: String
        
        /// The refresh token, if available.
        @objc public let refreshToken: String?
        
        /// The time interval after which this token will expire.
        @objc public let expiresIn: TimeInterval
        
        /// The ID token JWT string.
        @objc public let idToken: String?
        
        /// The access scopes for this token.
        @objc public let scope: String
        
        /// The type of this token.
        @objc public let tokenType: String

        internal init(accessToken: String,
                      refreshToken: String?,
                      expiresIn: TimeInterval,
                      idToken: String?,
                      scope: String,
                      tokenType: String)
        {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expiresIn = expiresIn
            self.idToken = idToken
            self.scope = scope
            self.tokenType = tokenType
            
            super.init()
        }
    }
    
    /// Provides information about the client application being authenticated against.
    @objc(IDXApplication)
    final class Application: NSObject {
        /// Unique identifier for this application.
        @objc(identifier)
        public let id: String
        
        /// Label for this application.
        @objc public let label: String
        
        /// Name for this application.
        @objc public let name: String
        
        internal init(id: String, label: String, name: String) {
            self.id = id
            self.label = label
            self.name = name
         
            super.init()
        }
    }

    /// Provides information about the user being authenticated.
    @objc(IDXUser)
    final class User: NSObject {
        /// Unique identifier for this user.
        @objc(identifier)
        public let id: String

        internal init(id: String) {
            self.id = id
         
            super.init()
        }
    }
    
    /// Represents information describing the available authenticators and enrolled authenticators.
    @objc(IDXAuthenticator)
    class Authenticator: NSObject {
        /// Unique identifier for this enrollment
        @objc(identifier)
        public let id: String

        /// The user-visible name to use for this authenticator enrollment.
        @objc public let displayName: String

        @objc public let key: String?

        /// The type of this authenticator, or `unknown` if the type isn't represented by this enumeration.
        @objc public let type: AuthenticatorType

        /// The string representation of this type.
        @objc public let typeName: String
        
        /// Describes the authenticator methods, as enums.
        @nonobjc public let methods: [AuthenticatorMethodType]?
        
        /// Describes the authenticator method names, as strings.
        @objc public let methodNames: [String]?

        internal init(id: String,
                      displayName: String,
                      type: String,
                      key: String?,
                      methods: [[String:String]]?)
        {
            self.id = id
            self.displayName = displayName
            self.type = AuthenticatorType(string: type)
            self.typeName = type
            self.key = key
            self.methods = methods?.compactMap {
                guard let type = $0["type"] else { return nil }
                return AuthenticatorMethodType(string: type)
            }
            self.methodNames = methods?.compactMap { $0["type"] }
         
            super.init()
        }

        /// Describes details about the current authenticator being enrolled, and any data associated with it.
        @objc(IDXCurrentAuthenticator)
        public final class Current: Authenticator {
            /// Optional contextual data, used for some enrolment types such as biometric.
            @objc public let contextualData: [String:AnyObject]?

            internal init(id: String,
                          displayName: String,
                          type: String,
                          key: String?,
                          methods: [[String:String]]?,
                          contextualData: [String:AnyObject]?)
            {
                self.contextualData = contextualData
             
                super.init(id: id, displayName: displayName, type: type, key: key, methods: methods)
            }
        }
        
        /// Describes details about the current authenticator enrollment being verified, and any extra actions that may be taken.
        @objc(IDXAuthenticatorEnrollment)
        public class Enrollment: Authenticator {
            /// Returns the enrollment's credential ID, if applicable.
            @objc public let credentialId: String?

            /// The profile information for the authenticator enrollment.
            ///
            /// This may contain information relevant to the user's enrolment, such as redacted email address, security question, etc.
            @objc public let profile: [String:String]?

            internal init(id: String,
                          displayName: String,
                          type: String,
                          key: String?,
                          methods: [[String:String]]?,
                          credentialId: String?,
                          profile: [String:String]?)
            {
                self.credentialId = credentialId
                self.profile = profile
             
                super.init(id: id, displayName: displayName, type: type, key: key, methods: methods)
            }
            
            /// Describes details about the current authenticator enrollment being verified, and any extra actions that may be taken.
            @objc(IDXCurrentAuthenticatorEnrollment)
            public final class Current: Enrollment {
                /// Action that can be taken by the user to send a verification/confirmation message to the user.
                @objc public let send: Remediation.Option?
                
                /// Action that can be taken by the user to resend a verification message to the user.
                @objc public let resend: Remediation.Option?
                
                /// Action that can be used to poll for authenticator verification that may occur out-of-band, such as email "magic link" verification.
                @objc public let poll: Remediation.Option?
                
                /// Action that can be used to recover the user's account.
                @objc public let recover: Remediation.Option?

                internal init(id: String,
                              displayName: String,
                              type: String,
                              key: String?,
                              methods: [[String:String]]?,
                              credentialId: String?,
                              profile: [String:String]?,
                              send: Remediation.Option?,
                              resend: Remediation.Option?,
                              poll: Remediation.Option?,
                              recover: Remediation.Option?)
                {
                    self.send = send
                    self.resend = resend
                    self.poll = poll
                    self.recover = recover
                 
                    super.init(id: id, displayName: displayName, type: type, key: key, methods: methods, credentialId: credentialId, profile: profile)
                }
            }
        }
        
        /// An enumeration describing the various types of authenticators.
        @objc(IDXAuthenticatorType)
        public enum AuthenticatorType: Int {
            case unknown
            case app
            case email
            case phone
            case password
            case security_question
            case device
            case security_key
            case federated
        }

        /// An enumeration describing the various authenticator methods that may be chosen by the user, when applicable.
        @objc(IDXAuthenticatorMethodType)
        public enum AuthenticatorMethodType: Int {
            case unknown
            case sms
            case voice
            case email
            case push
            case crypto
            case signedNonce
            case totp
            case password
            case webauthn
            case security_question
        }
    }

    /// The `IDXClient.Remediation` object describes the remediation steps the user, and application, can follow to proceed through the workflow.
    ///
    /// Nested remediation options can be accessed through keyed subscripting, for example:
    ///
    ///    response.remediation["select-authenticator-enroll"]
    ///
    /// This can be chained through to form values as well, such as:
    ///
    ///    response.remediation["identify"]["identifier"]
    @objc(IDXRemediation)
    final class Remediation: NSObject {
        /// The remediation type, described in the response payload.
        public var type: String
        
        /// The array of remediation options available to the developer to proceed through the authentication workflow.
        public let remediationOptions: [Option]
        
        /// Access individual remediation options based on their given name, as a string.
        @objc public subscript(name: String) -> Option? {
            get { remediationOptions.filter { $0.name == name }.first }
        }
        
        /// Access individual remediation options based on their given name, as a `RemediationType` enum.
        @nonobjc public subscript(type: RemediationType) -> Option? {
            get { remediationOptions.filter { $0.type == type }.first }
        }
        
        private weak var api: IDXClientAPIImpl?

        internal init(api: IDXClientAPIImpl, type: String, remediationOptions: [Option]) {
            self.api = api
            self.type = type
            self.remediationOptions = remediationOptions
         
            super.init()
        }
        
        /// Value object that stores the user-supplied values with their associated remediation FormValues.
        /// This simplifies the way data can be supplied to remediation forms without requiring state management
        /// to keep track of nested options, hierarchial data, required values, and so on.
        ///
        /// Example:
        ///    parameters.setValue("user@okta.com", identifierFormValue)
        ///    parameters[identifierFormValue] = "user@okta.com"
        @objc(IDXRemediationParameters)
        final public class Parameters: NSObject {
            internal var storage: [FormValue:Any] = [:]
            
            /// Convenience initializer for constructing parameters using the supplied keys/values.
            /// - Parameter parameters: Collection of `FormValue` objects, and their corresponding user-supplied values.
            convenience public init(_ parameters: [FormValue:Any]) {
                self.init()
                
                storage.merge(parameters, uniquingKeysWith: { return $1 })
            }
            
            /// Sets the user-supplied value for the given form Value.
            /// - Parameters:
            ///   - value: Value to set, or `nil` to unset.
            ///   - formValue: `FormValue` instance to associate this value with.
            public func setValue(_ value: Any?, for formValue: FormValue) {
                if let value = value {
                    storage[formValue] = value
                } else {
                    storage.removeValue(forKey: formValue)
                }
            }
            
            /// Returns the user-supplied value for the given value.
            /// *Note:* This will not show default values implicitly associated with the FormValue instance, only the values supplied to `setValue(:for:)`.
            /// - Parameter formValue: The form value to find a value for.
            /// - Returns: The assigned form value, or `nil` if none has been set yet.
            public func value(for formValue: FormValue) -> Any? {
                return storage[formValue] as Any?
            }
            
            @objc public subscript(formValue: FormValue) -> Any? {
                get {
                    value(for: formValue)
                }
                
                set (newValue) {
                    setValue(newValue, for: formValue)
                }
            }
        }
        
        /// Describes an individual value within a form, used to collect and submit information from the user to proceed through the authentication workflow.
        ///
        /// Nested form values can be accessed through keyed subscripting, for example:
        ///
        ///    credentialsFormValue["passcode"]
        @objc(IDXFormValue)
        final public class FormValue: NSObject {
            /// The programmatic name for this form value.
            @objc public let name: String?
            
            /// The user-readable label describing this form value.
            @objc public let label: String?
            
            /// The type of value expected from the client.
            @objc public let type: String?
            
            /// The value to send, if a default is provided from the Identity Engine.
            @objc public let value: AnyObject?
            
            /// Indicates if the form value is intended to be seen by the user.
            @objc public let visible: Bool
            
            /// Indicates whether or not the form value is read-only.
            @objc public let mutable: Bool
            
            /// Indicates whether or not the form value is required to successfully proceed through this remediation option.
            @objc public let required: Bool
            
            /// Indicates whether or not the value supplied in this form value should be considered secret, and not presented to the user.
            @objc public let secret: Bool
            
            /// For composite form fields, this contains the nested array of form values to group together.
            @objc public let form: [FormValue]?
            
            /// For form fields that have specific options the user can choose from (e.g. security question, passcode, etc), this indicates the different form options that should be displayed to the user.
            @objc public let options: [FormValue]?
            
            /// The list of messages sent from the server, or `nil` if no messages are available at the form value level.
            ///
            /// Messages reported from the server at the FormValue level should be considered relevant to the individual form field, and as a result should be displayed to the user alongside any UI elements associated with it.
            @objc public let messages: [Message]?
            
            /// Access form values based on their name.
            @objc public subscript(name: String) -> FormValue? {
                get { form?.filter { $0.name == name }.first }
            }
            
            /// Returns the related object within this response.
            ///
            /// Many times this is an Authenticator, Enrollment, etc.
            @objc public internal(set) var relatesTo: AnyObject?
            
            /// For composite or nested forms, this method composes the list of form values, merging the supplied parameters along with the defaults included in the form.
            ///
            /// Validation checks for required and immutable values are performed, which will throw exceptions if any of those parameters fail validation.
            /// - Parameter params: User-supplied parameters, `nil` to simply retrieve the defaults.
            /// - Throws:
            ///   - IDXClientError.invalidParameter
            ///   - IDXClientError.parameterImmutable
            ///   - IDXClientError.missingRequiredParameter
            /// - Returns: Collection of key/value pairs, or `nil` if this form value does not contain a nested form.
            /// - SeeAlso: IDXClient.Remediation.Option.formValues(with:)
            public func formValues(with params: [String:Any]? = nil) throws -> [String:Any]? {
                guard let form = form else { return nil }
                
                return try IDXClient.extractFormValues(from: form, with: params)
            }
            
            internal let v1RelatesTo: APIVersion1.Response.RelatesTo?
            internal init(name: String? = nil,
                          label: String? = nil,
                          type: String? = nil,
                          value: AnyObject? = nil,
                          visible: Bool,
                          mutable: Bool,
                          required: Bool,
                          secret: Bool,
                          form: [FormValue]? = nil,
                          relatesTo:APIVersion1.Response.RelatesTo? = nil,
                          options: [FormValue]? = nil,
                          messages: [Message]? = nil)
            {
                self.name = name
                self.label = label
                self.type = type
                self.value = value
                self.visible = visible
                self.mutable = mutable
                self.required = required
                self.secret = secret
                self.form = form
                self.v1RelatesTo = relatesTo
                self.options = options
                self.messages = messages
                
                super.init()
            }
        }

        /// Instances of `IDXClient.Remediation.Option` describe choices the user can make to proceed through the authentication workflow.
        ///
        /// Either simple or complex authentication scenarios consist of a set of steps that may be followed, but at some times the user may have a choice in what they use to verify their identity. For example, a user may have multiple choices in verifying their account, such as:
        ///
        /// 1. Password
        /// 2. Security Questions
        /// 3. Email verification
        /// 4. Other, customizable, verification steps.
        ///
        /// Each of the remediation options includes details about what form values should be collected from the user, and a description of the resulting request that should be sent to Okta to proceed to the next step.
        ///
        /// Nested form values can be accessed through keyed subscripting, for example:
        ///
        ///    remediationOption["identifier"]
        @objc(IDXRemediationOption)
        final public class Option: NSObject {
            /// The name of this remediation step, which can be used to control how the form is presented to the user.
            @objc public let name: String
            
            /// The enumeration type of this remediation step, based on the `name` value.
            @objc public let type: RemediationType
            
            /// The HTTP method to use when fulfiling this remediation.
            @objc public let method: String
            
            /// The URL for this remediation request.
            @objc public let href: URL
            
            /// The mime type this remediation request can support.
            @objc public let accepts: String
            
            /// A description of the form values that this remediation option supports and expects.
            @objc public let form: [FormValue]
            
            /// Returns the related object within this response.
            ///
            /// Many times this is an Authenticator, Enrollment, etc.
            @objc public internal(set) var relatesTo: [AnyObject]?
            
            /// When this remediation option is intended to be called after a fixed time delay, this value will represent the time interval to wait before performing the request.
            public let refresh: TimeInterval?
            
            /// Access a FormValue based on its name.
            @objc public subscript(name: String) -> FormValue? {
                get { form.filter { $0.name == name }.first }
            }

            private weak var api: IDXClientAPIImpl?
            internal let v1RelatesTo: [APIVersion1.Response.RelatesTo]?
            internal init(api: IDXClientAPIImpl,
                          name: String,
                          method: String,
                          href: URL,
                          accepts: String,
                          form: [FormValue],
                          relatesTo: [APIVersion1.Response.RelatesTo]?,
                          refresh: TimeInterval?)
            {
                self.api = api
                self.name = name
                self.type = RemediationType(string: name)
                self.method = method
                self.href = href
                self.accepts = accepts
                self.form = form
                self.v1RelatesTo = relatesTo
                self.refresh = refresh
                
                super.init()
            }
            
            /// Executes the remediation option and proceeds through the workflow using the supplied form parameters.
            ///
            /// This method is used to proceed through the authentication flow, using the given data to make the user's selection.
            /// - Important:
            /// If a completion handler is not provided, you should ensure that you implement the `IDXClientDelegate.idx(client:didReceive:)` methods to process any response or error returned from this call.
            /// - Parameters:
            ///   - dataFromUI: Form data collected from the user.
            ///   - completion: Optional completion handler invoked when a response is received.
            ///   - response: `IDXClient.Response` object describing the next step in the remediation workflow, or `nil` if an error occurred.
            ///   - error: A description of the error that occurred, or `nil` if the request was successful.
            @objc(proceedWithData:completion:)
            public func proceed(with dataFromUI: [String:Any] = [:], completion: ((_ response: Response?, _ error: Error?) -> Void)? = nil) {
                guard let client = api?.client else {
                    completion?(nil, IDXClientError.invalidClient)
                    return
                }
                
                do {
                    client.proceed(remediation: self,
                                   data: try self.formValues(with: dataFromUI),
                                   completion: completion)
                } catch {
                    completion?(nil, error)
                }
            }

            /// Executes the remediation option and proceeds through the workflow using the supplied form parameters.
            ///
            /// This method is used to proceed through the authentication flow, using the given data to make the user's selection. It accepts the user data as a `IDXClient.Remediation.Parameters` object to associate individual `IDXClient.Remediation.FormValue` fields to the associated user-supplied data to submit to the request.
            /// - Important:
            /// If a completion handler is not provided, you should ensure that you implement the `IDXClientDelegate.idx(client:didReceive:)` methods to process any response or error returned from this call.
            /// - Parameters:
            ///   - parameters: `IDXClient.Parameters` object representing the data to submit to the remediation option.
            ///   - completion: Optional completion handler invoked when a response is received.
            ///   - response: `IDXClient.Response` object describing the next step in the remediation workflow, or `nil` if an error occurred.
            ///   - error: A description of the error that occurred, or `nil` if the request was successful.
            @objc(proceedWithParameters:completion:)
            public func proceed(with parameters: Parameters, completion: ((_ response: Response?, _ error: Error?) -> Void)?) {
                guard let client = api?.client else {
                    completion?(nil, IDXClientError.invalidClient)
                    return
                }
                
                do {
                    client.proceed(remediation: self,
                                   data: try formValues(using: parameters),
                                   completion: completion)
                } catch {
                    completion?(nil, error)
                }
            }

            /// Apply the remediation option parameters, reconciling default values and mutability requirements.
            ///
            /// Validation checks for required and immutable values are performed, which will throw exceptions if any of those parameters fail validation.
            /// - Parameter params: User-supplied parameters, `nil` to simply retrieve the defaults.
            /// - Throws:
            ///   - IDXClientError.invalidParameter
            ///   - IDXClientError.parameterImmutable
            ///   - IDXClientError.missingRequiredParameter
            /// - Returns: Collection of key/value pairs, or `nil` if this form value does not contain a nested form.
            /// - SeeAlso: IDXClient.Remediation.FormValue.formValues(with:)
            @objc public func formValues(with params: [String:Any]? = nil) throws -> [String:Any] {
                return try IDXClient.extractFormValues(from: form, with: params)
            }
            
        }
    }
    
    /// Represents messages sent from the server to indicate error or warning conditions related to responses or form values.
    @objc(IDXMessage)
    final class Message: NSObject {
        /// Enumeration describing the type of message.
        @objc public enum MessageClass: Int {
            case error
            case info
            case unknown
        }
        
        /// The type of message received from the server
        @objc public let type: MessageClass
        
        /// A localization key representing this message.
        ///
        /// This allows the text represented by this message to be customized or localized as needed.
        @objc public let localizationKey: String?
        
        /// The default text for this message.
        @objc public let message: String
        
        internal init(type: String,
                      localizationKey: String?,
                      message: String)
        {
            self.type = MessageClass(string: type)
            self.localizationKey = localizationKey
            self.message = message
            
            super.init()
        }
    }
}
