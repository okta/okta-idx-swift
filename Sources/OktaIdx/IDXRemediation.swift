//
// Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
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

extension IDXClient {
    
//    /// Value object that stores the user-supplied values with their associated remediation FormValues.
//    /// This simplifies the way data can be supplied to remediation forms without requiring state management
//    /// to keep track of nested options, hierarchial data, required values, and so on.
//    ///
//    /// Example:
//    ///    parameters.setValue("user@okta.com", identifierFormValue)
//    ///    parameters[identifierFormValue] = "user@okta.com"
//    @objc(IDXRemediationParameters)
//    final public class Parameters: NSObject {
//        internal var storage: [FormValue:Any] = [:]
//        
//        convenience public init(_ parameters: [FormValue:Any]) {
//            self.init()
//            
//            storage.merge(parameters, uniquingKeysWith: { return $1 })
//        }
//        
//        /// Sets the user-supplied value for the given form Value.
//        /// - Parameters:
//        ///   - value: Value to set, or `nil` to unset.
//        ///   - formValue: `FormValue` instance to associate this value with.
//        public func setValue(_ value: Any?, for formValue: FormValue) {
//            if let value = value {
//                storage[formValue] = value
//            } else {
//                storage.removeValue(forKey: formValue)
//            }
//        }
//        
//        /// Returns the user-supplied value for the given value.
//        /// *Note:* This will not show default values implicitly associated with the FormValue instance, only the values supplied to `setValue(:for:)`.
//        /// - Parameter formValue: The form value to find a value for.
//        /// - Returns: The assigned form value, or `nil` if none has been set yet.
//        public func value(for formValue: FormValue) -> Any? {
//            return storage[formValue] as Any?
//        }
//        
//        @objc public subscript(formValue: FormValue) -> Any? {
//            get {
//                value(for: formValue)
//            }
//            
//            set (newValue) {
//                setValue(newValue, for: formValue)
//            }
//        }
//    }
    
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
    @objc(IDXRemediation)
    public class Remediation: NSObject {
        @objc public let type: RemediationType
        @objc public let name: String

        /// A description of the form values that this remediation option supports and expects.
        @objc public let form: Form
        
        @objc public internal(set) var authenticators: AuthenticatorCollection?
        
        @objc public subscript(name: String) -> Form.Field? {
            get { form.filter { $0.name == name }.first }
        }
        
        private weak var client: IDXClientAPI?
        
        let method: String
        let href: URL
        let accepts: String?
        let refresh: TimeInterval?

        internal init(client: IDXClientAPI,
                      name: String,
                      method: String,
                      href: URL,
                      accepts: String?,
                      form: Form,
                      refresh: TimeInterval?)
        {
            self.client = client
            self.name = name
            self.type = .init(string: name)
            self.method = method
            self.href = href
            self.accepts = accepts
            self.form = form
            self.refresh = refresh
            
            super.init()
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
        @objc
        public func proceed(completion: IDXClient.ResponseResult?) {
            guard let client = client else {
                completion?(nil, IDXClientError.invalidClient)
                return
            }
            
            client.proceed(remediation: self, completion: completion)
        }
        
//        /// Apply the remediation option parameters, reconciling default values and mutability requirements.
//        ///
//        /// Validation checks for required and immutable values are performed, which will throw exceptions if any of those parameters fail validation.
//        /// - Parameter params: User-supplied parameters, `nil` to simply retrieve the defaults.
//        /// - Throws:
//        ///   - IDXClientError.invalidParameter
//        ///   - IDXClientError.parameterImmutable
//        ///   - IDXClientError.missingRequiredParameter
//        /// - Returns: Collection of key/value pairs, or `nil` if this form value does not contain a nested form.
//        /// - SeeAlso: IDXClient.Remediation.FormValue.formValues(with:)
//        @objc public func formValues(with params: [String:Any]? = nil) throws -> [String:Any] {
//            return try IDXClient.extractFormValues(from: form, with: params)
//        }
        
        @objc(IDXSocialAuthRemediation)
        public class SocialAuth: Remediation {
            @objc public var redirectUrl: URL { href }
            @objc public let service: Service
            @objc(identifier) public let id: String
            @objc public let idpName: String
            
            init(client: IDXClientAPI,
                 name: String,
                 method: String,
                 href: URL,
                 accepts: String?,
                 form: IDXClient.Remediation.Form,
                 refresh: TimeInterval?,
                 id: String,
                 idpName: String,
                 service: Service)
            {
                self.id = id
                self.idpName = idpName
                self.service = service
                
                super.init(client: client,
                           name: name,
                           method: method,
                           href: href,
                           accepts: accepts,
                           form: form,
                           refresh: refresh)
            }
            
            @objc(IDXSocialAuthRemediationService)
            public enum Service: Int {
            case facebook
            case google
            case linkedin
            case other
            }
        }
    }
}
