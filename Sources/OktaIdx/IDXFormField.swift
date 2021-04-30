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

extension IDXClient.Remediation.Form {
    /// Describes an individual value within a form, used to collect and submit information from the user to proceed through the authentication workflow.
    ///
    /// Nested form values can be accessed through keyed subscripting, for example:
    ///
    ///    credentialsFormValue["passcode"]
    @objc(IDXRemediationFormField)
    final public class Field: NSObject {
        /// The programmatic name for this form value.
        @objc public let name: String?
        
        /// The user-readable label describing this form value.
        @objc public let label: String?
        
        /// The type of value expected from the client.
        @objc public let type: String?
        
        /// The value to send, if a default is provided from the Identity Engine.
        @objc public var value: AnyObject? {
            get { _value }
            set {
                guard isMutable else { return }
                _value = newValue
            }
        }
        
        /// Indicates whether or not the form value is read-only.
        @objc public let isMutable: Bool
        
        /// Indicates whether or not the form value is required to successfully proceed through this remediation option.
        @objc public let isRequired: Bool
        
        /// Indicates whether or not the value supplied in this form value should be considered secret, and not presented to the user.
        @objc public let isSecret: Bool
        
        /// For composite form fields, this contains the nested array of form values to group together.
        @objc public let form: IDXClient.Remediation.Form
        
        /// For form fields that have specific options the user can choose from (e.g. security question, passcode, etc), this indicates the different form options that should be displayed to the user.
        @objc public let options: [IDXClient.Remediation.Form]?
        
        @objc public weak var selectedOption: IDXClient.Remediation.Form? {
            didSet {
                guard let options = options else { return }
                for option in options {
                    option.isSelected = (option === selectedOption)
                }
            }
        }
        
        /// The list of messages sent from the server, or `nil` if no messages are available at the form value level.
        ///
        /// Messages reported from the server at the FormValue level should be considered relevant to the individual form field, and as a result should be displayed to the user alongside any UI elements associated with it.
        @objc public let messages: [IDXClient.Message]?
        
        @objc public internal(set) var authenticator: IDXClient.Authenticator?

        @objc public subscript(name: String) -> Field? {
            form[name]
        }
        
//        @objc public internal(set) var relatesTo: AnyObject?
//        internal let v1RelatesTo: APIVersion1.Response.RelatesTo?
        
//        /// For composite or nested forms, this method composes the list of form values, merging the supplied parameters along with the defaults included in the form.
//        ///
//        /// Validation checks for required and immutable values are performed, which will throw exceptions if any of those parameters fail validation.
//        /// - Parameter params: User-supplied parameters, `nil` to simply retrieve the defaults.
//        /// - Throws:
//        ///   - IDXClientError.invalidParameter
//        ///   - IDXClientError.parameterImmutable
//        ///   - IDXClientError.missingRequiredParameter
//        /// - Returns: Collection of key/value pairs, or `nil` if this form value does not contain a nested form.
//        /// - SeeAlso: IDXClient.Remediation.Option.formValues(with:)
//        public func formValues(with params: [String:Any]? = nil) throws -> [String:Any]? {
//            guard let form = form else { return nil }
//            
//            return try IDXClient.extractFormValues(from: form, with: params)
//        }
        
        var _value: AnyObject?
        internal init(name: String? = nil,
                      label: String? = nil,
                      type: String? = nil,
                      value: AnyObject? = nil,
                      visible: Bool,
                      mutable: Bool,
                      required: Bool,
                      secret: Bool,
                      form: IDXClient.Remediation.Form,
//                      relatesTo:APIVersion1.Response.RelatesTo? = nil,
                      options: [IDXClient.Remediation.Form]? = nil,
                      messages: [IDXClient.Message]? = nil)
        {
            self.name = name
            self.label = label
            self.type = type
            self._value = value
            self.isMutable = mutable
            self.isRequired = required
            self.isSecret = secret
            self.form = form
//            self.v1RelatesTo = relatesTo
            self.options = options
            self.messages = messages
            
            super.init()
        }
    }
    
}
