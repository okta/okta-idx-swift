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
    public private(set) var currentResponse: Response?
    public private(set) var currentForm: SignInForm?

    public init() {}
    
    public let loading: SignInForm = SignInForm(intent: .loading) {
        HeaderSection(id: "loading") {
            Loading(id: "loadingIndicator")
        }
    }
    
    public let success: SignInForm = SignInForm(intent: .loading) {
        HeaderSection(id: "title") {
            FormLabel(id: "titleLabel", text: "Signing in", style: .heading)
            Loading(id: "loadingIndicator")
        }
    }
    
    public func form(for response: Response) -> SignInForm {
        currentResponse = response
        let result: SignInForm
        
        do {
            result = try response.form(previous: currentForm)
        } catch {
            result = self.form(for: error)
        }
        
        currentForm = result
        return result
    }
    
    public func form(for error: Error) -> SignInForm {
        var form = currentForm ?? SignInForm(intent: .empty) {}
        
        var messageSection: any SignInSection
        if let section = form.sections.with(id: "title") {
            messageSection = section
        } else {
            messageSection = HeaderSection(id: "title") {
                FormLabel(id: "titleLabel", text: "Error signing in", style: .heading)
            }
            form.sections.insert(messageSection, at: 0)
        }
        
        var message = error.localizedDescription
        var componentIdentifier = "title.titleLabel"
        
        if let error = error as? InteractionCodeFlowError {
            switch error {
            case .invalidParameter(name: let name),
                    .invalidParameterValue(name: let name, type: _):
                switch name {
                case "identifier":
                    message = "The username is incorrect"
                    
                default: break
                }
                
            case .missingRequiredParameter(name: let name):
                switch name {
                case "identifier":
                    message = "Please provide a username"
                default: break
                }
            default: break
            }
        }
        
        if var errorLabel: FormLabel = messageSection.components.with(id: "errorDescription") {
            errorLabel.text = message
        } else {
            messageSection.components.append(FormLabel(id: "errorDescription",
                                                       text: message,
                                                       style: .error))
        }
        
        if let headerIndex = form.sections.firstIndex(where: { $0.id == messageSection.id }) {
            form.sections[headerIndex] = messageSection
        }
        
        currentForm = form
        return form
    }
}

extension SignInForm {
    func value(for fieldName: String?, in sectionName: String?) -> SignInValue<String>? {
        guard let fieldName = fieldName,
              let sectionName = sectionName,
              let component: StringInputField = sections
            .first(where: { $0.id == fieldName })?
            .component(with: sectionName)
        else {
            return nil
        }
        
        return component.value
    }
}

extension Response {
    func form(previous: SignInForm?) throws -> SignInForm {
        var sections: [any SignInSection] = try remediations.compactMap { [weak self] remediation in
            try remediation.section(from: self, previous: previous)
        }
        
        if messages.count > 0 {
            let components = messages.map({ message in
                FormLabel(id: UUID().uuidString,
                          text: message.message,
                          style: .error)
            })
            sections.insert(HeaderSection(id: "errors") {
                components
            }, at: 0)
        }
        
        sections.insert(HeaderSection(id: "title") {
            FormLabel(id: "titleLabel", text: "Sign in", style: .heading)
        }, at: 0)
        
        // Coalesce all redirect-idp actions together
        let idpSections: [RedirectIDP] = sections
            .compactMap({ $0 as? RedirectIDP })

        let idpProviders = idpSections
            .map({ $0.providers })
            .reduce([], +)

        let idpComponents = idpSections
            .compactMap({ $0.components })
            .reduce([], +)

        if !idpComponents.isEmpty,
           let firstIndex = sections.firstIndex(where: { $0 is RedirectIDP })
        {
            sections.removeAll(where: { $0 is RedirectIDP })
            sections.insert(RedirectIDP(id: "redirect-idp", providers: idpProviders) {
                idpComponents
            }, at: firstIndex)
        }
        
        return SignInForm(intent: .signIn) { sections }
    }
}

extension OktaIdx.Authenticator {
    var authenticatorModel: (any NativeAuthentication.Authenticator)? {
        guard let displayName = displayName else {
            return nil
        }
        
        switch type {
        case .email:
            var result = EmailAuthenticator(name: displayName)
                .profile(capability(Capability.Profile.self)?.values["email"])
            
            if let sendable = capability(Capability.Sendable.self) {
                result.send = {
                    sendable.send()
                }
            }

            if let resendable = capability(Capability.Resendable.self) {
                result.resend = {
                    resendable.resend()
                }
            }
            
            if let pollable = capability(Capability.Pollable.self) {
                result.startPolling = {
                    pollable.startPolling()
                }
                
                result.stopPolling = {
                    pollable.stopPolling()
                }
            }
            
            return result
            
        default:
            return nil
        }
    }
}

//extension Authenticator

extension Capability.SocialIDP {
    var provider: RedirectIDP.Provider? {
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
    func action() -> (any Action)? {
        switch type {
        case .cancel:
            return ContinueAction(id: "\(name).continue",
                                  intent: .restart,
                                  label: "Restart") {
                self.proceed()
            }
            
        case .redirectIdp:
            guard let socialIdp = socialIdp,
                  let provider = socialIdp.provider,
                  let label = socialIdp.label
            else {
                return nil
            }
            
            return SocialLoginAction(id: "\(name).\(socialIdp.idpName).continue",
                                     provider: provider,
                                     label: label) {
                print("Social login triggered")
            }
            
        case .selectEnrollProfile:
            return ContinueAction(id: "\(name).continue",
                                  intent: .signUp,
                                  label: "Sign up") {
                self.proceed()
            }
            
        case .identify:
            return ContinueAction(id: "\(name).signIn",
                                  intent: .signIn,
                                  label: "Sign in") {
                self.proceed()
            }
            
        case .selectIdentify:
            return ContinueAction(id: "\(name).signIn",
                                  intent: .signIn,
                                  label: "Sign in with a username") {
                self.proceed()
            }
            
        case .selectAuthenticatorAuthenticate,
                .selectAuthenticatorEnroll,
                .selectAuthenticatorUnlockAccount:
            return ContinueAction(id: "\(name).signIn",
                                  intent: .continue,
                                  label: "Select authenticator method") {
                self.proceed()
            }
            
        default:
            return ContinueAction(id: "\(name).continue",
                                  intent: .continue,
                                  label: "Continue") {
                self.proceed()
            }
        }
    }

    func section(from response: Response?, previous: SignInForm?) throws -> (any SignInSection)? {
        guard let response = response else { return nil }
        
        var components: [any SignInComponent] = form.fields.compactMap { field in
            field.remediationRow(from: response, remediation: self, previous: previous)
        }.reduce([], +)
                
        self.messages.forEach { message in
            components.append(FormLabel(id: UUID().uuidString,
                                        text: message.message,
                                        style: .caption))
        }
        
        if let actionComponent = action() {
            components.append(actionComponent)
        }
        
        let result: any SignInSection
        
        switch type {
        case .cancel:
            result = RestartSignIn {
                components
            }.action { component in
                self.proceed()
            }
            
        case .redirectIdp:
            guard let socialIdp = socialIdp,
                  let provider = socialIdp.provider
            else {
                return nil
            }
            
            result = RedirectIDP(providers: [provider]) {
                components
            }
            
        case .selectEnrollProfile:
            result = MakeSelection(selection: .enrollProfile) {
                components
            }.action { component in
                self.proceed()
            }

        case .identify:
            result = IdentifyUser {
                components
            }

        case .enrollProfile:
            result = RegisterUser {
                components
            }
            
        case .selectIdentify:
            result = MakeSelection(selection: .identify) {
                components
            }.action { component in
                self.proceed()
            }

        case .selectAuthenticatorAuthenticate:
            result = SelectAuthenticator(intent: .authenticate) {
                components
            }

        case .selectAuthenticatorEnroll:
            result = SelectAuthenticator(intent: .enroll) {
                components
            }

        case .selectAuthenticatorUnlockAccount:
            result = SelectAuthenticator(intent: .recover) {
                components
            }
            
        case .challengeAuthenticator:
            guard let authenticator = authenticators.current?.authenticatorModel else { fallthrough }
            result = ChallengeAuthenticator(authenticator: authenticator) {
                components
            }

        case .authenticatorVerificationData:
            // TODO: Support this more later
            print("Skipping \(self)")
            return nil
            
        default:
            result = GenericSection {
                components
            }
        }
        
        return result.id(name)
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
                        previous: SignInForm?,
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
            if let options = options {
                options.forEach { field in
                    guard let label = field.label,
                          let authenticator = field.authenticator,
                          let authenticatorModel = authenticator.authenticatorModel
                    else {
                        return
                    }
                    
                    let id = remediation.name + "." + label
                    rows.append(AuthenticatorOption(
                        id: id,
                        authenticator: authenticatorModel)
                        .name(authenticator.type.rawValue)
                        .label(label)
                        .isCurrentOption(response.authenticators.current == authenticator)
                        .action { component in
                            self.selectedOption = field
                            remediation.proceed()
                        })
                }
            }
            
            else if let form = form {
                rows.append(contentsOf: form.flatMap { nested in
                    nested.remediationRow(from: response,
                                          remediation: remediation,
                                          previous: previous,
                                          ancestors: ancestors + [self])
                })
            }

        default:
            if let options = options {
//                rows.append(Row(kind: .select(field: self, values: options),
//                                parent: parent,
//                                delegate: delegate))
                print("What do I do?")
            } else if let form = form {
                rows.append(contentsOf: form.flatMap { nested in
                    nested.remediationRow(from: response,
                                          remediation: remediation,
                                          previous: previous,
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

                rows.append(StringInputField(id: id(remediation: remediation, ancestors: ancestors),
                                             label: label ?? "",
                                             isSecure: isSecret,
                                             inputStyle: style,
                                             contentType: contentType,
                                             value: previous?.value(for: remediation.name, in: name) ?? SignInValue(self)))
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
