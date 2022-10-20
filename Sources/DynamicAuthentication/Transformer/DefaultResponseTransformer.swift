//
// Copyright (c) 2022-Present, Okta, Inc. and/or its affiliates. All rights reserved.
// The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and limitations under the License.
//

import OktaIdx
import NativeAuthentication
import Foundation

public class DefaultResponseTransformer: ResponseTransformer {
    public init() {}
    
    public let loading: SignInForm = SignInForm(intent: .loading) {
        SignInSection(.header, id: "loading") {
            Loading(id: "loadingIndicator")
        }
    }
    
    public let success: SignInForm = SignInForm(intent: .loading) {
        SignInSection(.header, id: "title") {
            FormLabel(id: "titleLabel", text: "Signing in", style: .heading)
            Loading(id: "loadingIndicator")
        }
    }
    
    public func form(for response: Response) -> SignInForm {
        do {
            return try response.form()
        } catch {
            return form(for: error)
        }
    }
    
    public func form(for error: Error) -> SignInForm {
        SignInForm(intent: .empty) {
            SignInSection(.header, id: "error") {
                FormLabel(id: "errorMessage", text: "Error loading the page", style: .description)
                FormLabel(id: "errorDescription", text: error.localizedDescription, style: .error)
            }
        }
    }
}

extension Response {
    func form() throws -> SignInForm {
        var sections: [SignInSection] = try remediations.compactMap { [weak self] remediation in
            try remediation.section(from: self)
        }
        
        if messages.count > 0 {
            sections.insert(SignInSection(.header, id: "errors", components: messages.map({ message in
                FormLabel(id: UUID().uuidString,
                          text: message.message,
                          style: .error)
            })), at: 0)
        }
        
        sections.insert(SignInSection(.header, id: "title") {
            FormLabel(id: "titleLabel", text: "Sign in", style: .heading)
        }, at: 0)
        
        // Coalesce all redirect-idp actions together
        let idpComponents = sections
            .filter({ $0.id.hasPrefix("redirect-idp") })
            .compactMap({ $0.components }).reduce([], +)

        if !idpComponents.isEmpty,
           let firstIndex = sections.firstIndex(where: { $0.id.hasPrefix("redirect-idp") })
        {
            sections.removeAll(where: { $0.id.hasPrefix("redirect-idp") })
            
            let newSection = SignInSection(.body, id: "redirect-idp", components: idpComponents)
            sections.insert(newSection, at: firstIndex)
        }
        
        return SignInForm(intent: .signIn,
                          sections: sections)
    }
}

extension Capability.SocialIDP {
    var provider: SocialLoginAction.Provider? {
        switch service {
        case .apple:
            return .apple
        case .okta:
            return .okta
        case .facebook:
            return .facebook
        case .google:
            return .google
        case .linkedin:
            return .linkedin
        case .microsoft:
            return .microsoft
        case .oidc:
            return .other(idpName)
        default:
            return nil
        }
    }
    
    var label: String? {
        switch service {
        case .apple:
            return "Sign in with Apple"
        case .okta:
            return "Sign in with Okta"
        case .facebook:
            return "Sign in with Facebook"
        case .google:
            return "Sign in with Google"
        case .linkedin:
            return "Sign in with Linkedin"
        case .microsoft:
            return "Sign in with Microsoft"
        case .oidc:
            return "Sign in with \(idpName)"
        default:
            return nil
        }
    }
}

extension Remediation {
    func section(from response: Response?) throws -> SignInSection? {
        guard let response = response else { return nil }
        
        var components: [any SignInComponent] = form.fields.compactMap { field in
            field.remediationRow(from: response, remediation: self)
        }.reduce([], +)
                
        self.messages.forEach { message in
            components.append(FormLabel(id: UUID().uuidString,
                                        text: message.message,
                                        style: .caption))
        }
        
        var id = name
        switch type {
        case .cancel:
            components.append(ContinueAction(id: "\(name).continue",
                                             intent: .restart,
                                             label: "Restart") {
                self.proceed()
            })
            
        case .redirectIdp:
            guard let socialIdp = socialIdp else { break }
            id = "\(name).\(socialIdp.idpName)"
            
            if let provider = socialIdp.provider,
               let label = socialIdp.label
            {
                components.append(SocialLoginAction(id: "\(id).continue",
                                                    provider: provider,
                                                    label: label) {
                    print("Social login triggered")
                })
            }
            
        case .selectEnrollProfile:
            components.append(ContinueAction(id: "\(name).continue",
                                             intent: .signUp,
                                             label: "Sign up") {
                self.proceed()
            })

        case .identify:
            components.append(ContinueAction(id: "\(name).signIn",
                                             intent: .signIn,
                                             label: "Sign in") {
                self.proceed()
            })

        case .selectIdentify:
            components.append(ContinueAction(id: "\(name).signIn",
                                             intent: .signIn,
                                             label: "Sign in with a username") {
                self.proceed()
            })

        default:
            components.append(ContinueAction(id: "\(name).continue",
                                             intent: .continue,
                                             label: "Continue") {
                self.proceed()
            })
        }

        return SignInSection(.body, id: id, components: components) { component in
            print("Triggered section action")
        }
    }
}

extension Remediation.Form.Field {
    func id(remediation: Remediation, ancestors: [Remediation.Form.Field]) -> String {
        var ancestors = ancestors
        ancestors.append(self)
        
        var result = remediation.name
        for (index, field) in ancestors.enumerated() {
            if let name = field.name {
                result += ".\(name)"
            } else if index > 0,
                      let options = ancestors[index - 1].options,
                      let currentIndex = options.firstIndex(of: field)
            {
                result += "[\(currentIndex)]"
            }
        }
        
        return result
    }

    func remediationRow(from response: Response,
                        remediation: Remediation,
                        ancestors: [Remediation.Form.Field] = []) -> [any SignInComponent]
    {
        if !isMutable {
            if label != nil {
                // Fields that are not "visible" don't mean they shouldn't be displayed, just that they
                return [
                    FormLabel(id: id(remediation: remediation, ancestors: ancestors),
                              text: label ?? "")
                ]
            } else {
                return []
            }
        }

        var rows: [any SignInComponent] = []

        switch type {
        case "boolean": break
//            rows.append(Row(kind: .toggle(field: self),
//                            parent: parent,
//                            delegate: delegate))
        case "object":
//            if let options = options {
//                options.forEach { option in
//                    rows.append(Row(kind: .option(field: self, option: option),
//                                    parent: parent,
//                                    delegate: delegate))
//                    if option.isSelectedOption,
//                       let form = option.form
//                    {
//                        rows.append(contentsOf: form.flatMap { nested in
//                            nested.remediationRow(delegate: delegate)
//                        })
//                    }
//                }
//            } else
        if let form = form {
                rows.append(contentsOf: form.flatMap { nested in
                    nested.remediationRow(from: response,
                                          remediation: remediation,
                                          ancestors: ancestors + [self])
                })
            }

        default:
            if let options = options {
//                rows.append(Row(kind: .select(field: self, values: options),
//                                parent: parent,
//                                delegate: delegate))
            } else if let form = form {
                rows.append(contentsOf: form.flatMap { nested in
                    nested.remediationRow(from: response,
                                          remediation: remediation,
                                          ancestors: ancestors + [self])
                })
            } else {
                let style: StringInputField.InputStyle
                let contentType: StringInputField.ContentType
                
                switch name {
                case "identifier":
                    style = .email
                    contentType = .username
                case "email":
                    style = .email
                    contentType = .emailAddress
                case "passcode":
                    if let authenticator = authenticator ?? response.authenticators.current {
                        style = .password

                        switch authenticator.type {
                        case .password:
                            contentType = .password
                        default:
                            contentType = .oneTimeCode
                        }
                    } else {
                        style = .password
                        contentType = .generic
                    }
                default:
                    style = .generic
                    contentType = .generic
                }

//                if isSecret {
//                    style = .password
//                }

                rows.append(StringInputField(id: id(remediation: remediation, ancestors: ancestors),
                                             label: label ?? "",
                                             isSecure: isSecret,
                                             inputStyle: style,
                                             contentType: contentType,
                                             value: SignInValue(self)))
            }
        }

        self.messages.forEach { message in
            rows.append(FormLabel(id: UUID().uuidString,
                                  text: message.message,
                                  style: .error))
        }

        return rows
    }
}
