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
    
    public func form(for response: Response, in provider: DynamicAuthenticationProvider) -> SignInForm {
        guard !response.remediations.isEmpty else {
            let error = response.errors.first ?? DynamicAuthenticationError.terminal
            provider.restart(with: error)
            return .loading
        }
        
        currentResponse = response
        let result: SignInForm
        
        do {
            result = try response.form(previous: currentForm, in: provider)
        } catch {
            result = self.form(for: error, in: provider)
        }
        
        currentForm = result
        return result
    }
    
    public func shouldUpdateForm(for response: Response) -> Bool {
        // Auto-enrollment handling
        if let remediation = response.remediations[.selectAuthenticatorEnroll] ?? response.remediations[.selectAuthenticatorAuthenticate] ?? response.remediations[.selectAuthenticatorUnlockAccount],
           let authenticatorField = remediation["authenticator"],
           let options = authenticatorField.options,
           response.remediations[.skip] == nil
        {
            // Automatically follow when there's only one option
            if options.count == 1,
               let option = options.first,
               response.authenticators.current != option.authenticator
            {
                authenticatorField.selectedOption = option
                remediation.proceed()
                return false
            }
            
            // Automatically enroll the password when it's one of the options while enrolling
            else if let passwordOption = options.first(where: { $0.authenticator?.type == .password }),
                    remediation.type == .selectAuthenticatorEnroll,
                    response.authenticators.current != passwordOption.authenticator
            {
                authenticatorField.selectedOption = passwordOption
                remediation.proceed()
                return false
            }
        }
        
        return true
    }

    public func form(for error: Error, in provider: DynamicAuthenticationProvider) -> SignInForm {
        var form = currentForm ?? SignInForm(intent: .empty) {}
        
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
        
        let headerIndex = form.sections.firstIndex(where: { $0 is HeaderSection })

        var messageSection: ErrorSection
        if let index = form.sections.index(of: "errors"),
           let section = form.sections[index] as? ErrorSection
        {
            messageSection = section
            form.sections.remove(at: index)
        } else {
            messageSection = ErrorSection(id: "errors") {
                if headerIndex == nil {
                    FormLabel(id: "titleLabel", text: "Error signing in", style: .heading)
                }
            }
        }

        messageSection.components.append(
            FormLabel(id: "errorDescription",
                      text: message,
                      style: .error)
        )
        
        var sections = form.sections
        if let headerIndex = headerIndex {
            sections.insert(messageSection, at: headerIndex + 1)
        } else {
            sections.insert(messageSection, at: 0)
        }
        form.sections = sections
        
        currentForm = form
        return form
    }
}

extension Response {
    func form(previous: SignInForm?, in provider: DynamicAuthenticationProvider) throws -> SignInForm {
        var sections: [any SignInSection] = try remediations.compactMap { [weak self] remediation in
            try remediation.section(from: self, previous: previous, in: provider)
        }
        
        var headerSection = HeaderSection(id: "title") {
            FormLabel(id: "titleLabel", text: "Sign in", style: .heading)
        }
        
        updateMessages(&sections)
        updateIDPSection(&sections)
        updateAuthenticatorSections(&sections)
        updateBackButton(&sections, header: &headerSection)
        updateRestartButton(&sections, header: &headerSection)

        sections.insert(headerSection, at: 0)

        return SignInForm(intent: .signIn) { sections }
    }
    
    var errors: [Error] {
        messages
            .filter { $0.type == .error }
            .map { DynamicAuthenticationError.message($0.message,
                                         localizationKey: $0.localizationKey) }
    }
    
    func updateMessages(_ sections: inout [any SignInSection]) {
        if messages.count > 0 {
            let components = messages.map({ message in
                FormLabel(id: UUID().uuidString,
                          text: message.message,
                          style: .error)
            })
            sections.insert(ErrorSection(id: "errors") {
                components
            }, at: 0)
        }
    }
    
    // Coalesce all redirect-idp actions together
    func updateIDPSection(_ sections: inout [any SignInSection]) {
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
    }
    
    func updateBackButton(_ sections: inout [any SignInSection], header headerSection: inout HeaderSection) {
        guard let index = sections.firstIndex(where: { $0.id == "select-identify" }),
           let action: ContinueAction = sections[index].component(with: "signIn")
        else {
            return
        }

        headerSection.leftComponents.append(action)
        sections.remove(at: index)
    }
    
    // Add the "Restart" button when appropriate
    func updateRestartButton(_ sections: inout [any SignInSection], header headerSection: inout HeaderSection) {
        guard let index = sections.firstIndex(where: { $0.id == "cancel" }),
           let action: ContinueAction = sections[index].component(with: "continue")
        else {
            return
        }

        headerSection.rightComponents.append(action)
        sections.remove(at: index)
    }
    
    func updateAuthenticatorSections(_ sections: inout [any SignInSection]) {
        guard let useSection = sections.compactMap({ $0 as? HasAuthenticator }).first,
              var selectSection = sections.of(type: SelectAuthenticator.self).first
        else {
            return
        }

        let authenticatorOptions = selectSection.components.of(type: AuthenticatorOption.self)

        // If only one authenticator is present, don't show the select-authenticator.
        if authenticatorOptions.count == 1,
           let index = sections.firstIndex(where: { $0 is SelectAuthenticator })
        {
            sections.remove(at: index)
        }
        
        // Remove the current authenticator option from the list
        else if let sectionIndex = sections.firstIndex(where: { $0 is SelectAuthenticator }),
                let componentIdx = selectSection.components.firstIndex(where: { component in
                    guard let component = component as? AuthenticatorOption else { return false }
                    return component.authenticator.id == useSection.authenticator.id
                })
        {
            selectSection.components.remove(at: componentIdx)
            sections[sectionIndex] = selectSection
        }
    }
}

extension OktaIdx.Authenticator {
    var authenticatorModel: (any NativeAuthentication.Authenticator)? {
        guard let id = id,
              let displayName = displayName
        else {
            return nil
        }
        
        switch type {
        case .email:
            var result = EmailAuthenticator(id: id, name: displayName)
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
            
        case .phone:
            var result = PhoneAuthenticator(id: id, name: displayName)
                .profile(capability(Capability.Profile.self)?.values["phoneNumber"])
            
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
            
            return result

        case .password:
            var result = PasswordAuthenticator(id: id, name: displayName)
            return result
            
        default:
            return nil
        }
    }
}

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
    func action(in provider: DynamicAuthenticationProvider) -> (any Action)? {
        switch type {
        case .cancel:
            return ContinueAction(id: "\(name).continue",
                                  intent: .restart,
                                  label: "Restart") {
                self.proceed()
            }
            
        case .redirectIdp:
            guard let socialIdp = socialIdp,
                  let redirectProvider = socialIdp.provider,
                  let label = socialIdp.label,
                  let scheme = provider.flow.redirectUri.scheme
            else {
                return nil
            }
            
            return SocialLoginAction(id: "\(name).\(socialIdp.idpName).continue",
                                     provider: redirectProvider,
                                     label: label) {
                provider.redirectIdp(provider: redirectProvider,
                                     url: socialIdp.redirectUrl,
                                     callback: scheme)
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
                                  intent: .back,
                                  label: "Sign in with a username") {
                self.proceed()
            }
            
        case .selectAuthenticatorAuthenticate,
                .selectAuthenticatorEnroll,
                .selectAuthenticatorUnlockAccount:
            return nil

        case .challengeAuthenticator:
            return ContinueAction(id: "\(name).continue",
                                  intent: .continue,
                                  label: "Verify") {
                self.proceed()
            }

        case .authenticatorVerificationData:
            let label: String
            if let authenticatorLabel = form["authenticator"]?.label {
                label = "Verify using \(authenticatorLabel)"
            } else {
                label = "Verify account"
            }
            
            return ContinueAction(id: "\(name).continue",
                                  intent: .continue,
                                  label: label) {
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

    func section(from response: Response?, previous: SignInForm?, in provider: DynamicAuthenticationProvider) throws -> (any SignInSection)? {
        guard let response = response else { return nil }
        
        var components: [any SignInComponent] = form.fields.compactMap { field in
            field.remediationRow(from: response, remediation: self, previous: previous)
        }.reduce([], +)
         
        let messageLabels: [any SignInComponent] = messages.compactMap({ message in
            guard message.field == nil else { return nil }
            return FormLabel(id: UUID().uuidString,
                             text: message.message,
                             style: .caption)
        })
        components.append(contentsOf: messageLabels)
        
        authenticators
            .compactMap { authenticator in
                authenticator.capability(Capability.Recoverable.self)
            }
            .forEach { recoverable in
                components.append(RecoverAction(id: "\(name).recover") {
                    recoverable.recover()
                })
            }
        
        if let actionComponent = action(in: provider) {
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
            guard let authenticator = authenticators.current?.authenticatorModel else { return nil }
            result = ChallengeAuthenticator(authenticator: authenticator) {
                components
            }

        case .authenticatorVerificationData:
            guard let authenticator = authenticators.current,
                  let authenticatorModel = authenticator.authenticatorModel
            else { return nil }

            if let methodType = form["authenticator.methodType"],
               let methodOptions = methodType.options
            {
                switch methodOptions.count {
                case 0:
                    return nil
                case 1:
                    methodType.selectedOption = methodOptions.first
                default:
                    print("Give the user an option")
                }
            }
            
            result = UseAuthenticator(authenticator: authenticatorModel) {
                components
            }
            
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
        case "boolean":
            let previousField: BooleanOption? = previous?
                .sections
                .with(id: remediation.name)?
                .component(with: name)

            // Set a sensible default so things don't crash
            if value == nil {
                switch name {
                case "rememberMe":
                    value = true
                default:
                    value = false
                }
            }

            rows.append(BooleanOption(id: id(remediation: remediation, ancestors: ancestors),
                                      label: label ?? "",
                                      value: previousField?.value ?? SignInValue(self)))

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

                // Carry the previous value over when the form hasn't changed.
                if let previousField: StringInputField = previous?
                    .sections
                    .with(id: remediation.name)?
                    .component(with: name)
                {
                    value = previousField.value.value
                }
                
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
