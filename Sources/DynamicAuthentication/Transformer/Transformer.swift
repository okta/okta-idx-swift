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

public protocol ResponseTransformer {
    func signInForm(for response: Response) -> SignInForm
    func signInForm(for error: Error) -> SignInForm
}

public struct DefaultResponseTransformer: ResponseTransformer {
    public init() {}
    
    public func signInForm(for response: Response) -> SignInForm {
        do {
            return try response.form()
        } catch {
            return signInForm(for: error)
        }
    }
    
    public func signInForm(for error: Error) -> SignInForm {
        SignInForm(intent: .empty, sections: [
            HeaderSection(id: "error", components: [
                FormLabel(id: "errorMessage", text: "Error loading the page", style: .description),
                FormLabel(id: "errorDescription", text: error.localizedDescription, style: .caption),
            ])
        ])
    }

}

extension Response {
    func form() throws -> SignInForm {
        var sections: [any SignInSection] = try remediations.compactMap { [weak self] remediation in
            try remediation.section(from: self)
        }
        
        sections.insert(HeaderSection(id: "title", components: [
            FormLabel(id: "titleLabel", text: "Sign in", style: .heading)
        ]), at: 0)
        
        return SignInForm(intent: .signIn,
                          sections: sections)
    }
}

extension Remediation {
    func section(from response: Response?) throws -> (any SignInSection)? {
        guard let response = response else { return nil }
        
        var components: [any SignInComponent] = form.fields.compactMap { field in
            field.remediationRow(from: response, remediation: self)
        }.reduce([], +)
        
        switch type {
        case .cancel:
            components.append(ContinueAction(id: "\(name).continue",
                                             intent: .restart,
                                             label: "Restart") {
                print("Triggered \(self.name)")
            })

        default:
            components.append(ContinueAction(id: "\(name).continue",
                                             intent: .signIn,
                                             label: "Sign in") {
                Task {
                    do {
                        try await self.proceed()
                    } catch {
                        print(error)
                    }
                }
            })
        }
        
        return InputSection(id: name, components: components)
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
                rows.append(StringInputField(id: id(remediation: remediation, ancestors: ancestors),
                                             label: label ?? "",
                                             isSecure: isSecret,
                                             value: value?.stringValue ?? ""))
            }
        }

        self.messages.forEach { message in
            rows.append(FormLabel(id: UUID().uuidString,
                                  text: message.message,
                                  style: .caption))
        }

        return rows
    }
}

    /*
public protocol ComponentTransformer {
    func transform(_ response: Response) throws -> any Component
    func transform(_ remediation: Remediation) throws -> any Component
    func transform(_ form: Remediation.Form) throws -> any Component
    func transform(_ field: Remediation.Form.Field) throws -> any Component
}

struct DefaultTransformer: ComponentTransformer {
    func transform(_ remediation: Remediation) throws -> (any Component)? {
        switch remediation.type {
        case .identify:
            return Group {
                Label("Sign in")
                    .style(.heading)
                for field in remediation.form.fields {
                    TextInput(
                }
            }
            
//        case .identifyRecovery:
//            <#code#>
//        case .selectIdentify:
//            <#code#>
//        case .selectEnrollProfile:
//            <#code#>
//        case .cancel:
//            <#code#>
//        case .sendChallenge:
//            <#code#>
//        case .resendChallenge:
//            <#code#>
//        case .selectAuthenticatorAuthenticate:
//            <#code#>
//        case .selectAuthenticatorUnlockAccount:
//            <#code#>
//        case .selectAuthenticatorEnroll:
//            <#code#>
//        case .selectEnrollmentChannel:
//            <#code#>
//        case .authenticatorVerificationData:
//            <#code#>
//        case .authenticatorEnrollmentData:
//            <#code#>
//        case .enrollmentChannelData:
//            <#code#>
//        case .challengeAuthenticator:
//            <#code#>
//        case .enrollPoll:
//            <#code#>
//        case .enrollAuthenticator:
//            <#code#>
//        case .reenrollAuthenticator:
//            <#code#>
//        case .reenrollAuthenticatorWarning:
//            <#code#>
//        case .resetAuthenticator:
//            <#code#>
//        case .enrollProfile:
//            <#code#>
//        case .unlockAccount:
//            <#code#>
//        case .deviceChallengePoll:
//            <#code#>
//        case .deviceAppleSsoExtension:
//            <#code#>
//        case .launchAuthenticator:
//            <#code#>
//        case .redirectIdp:
//            <#code#>
//        case .cancelTransaction:
//            <#code#>
//        case .skip:
//            <#code#>
//        case .challengePoll:
//            <#code#>
//        case .cancelPolling:
//            <#code#>
//        case .consent:
//            <#code#>
//        case .adminConsent:
//            <#code#>
//        case .emailChallengeConsent:
//            <#code#>
//        case .requestActivationEmail:
//            <#code#>
//        case .userCode:
//            <#code#>
//        case .poll:
//            <#code#>
//        case .recover:
//            <#code#>
//        case .send:
//            <#code#>
//        case .resend:
//            <#code#>
        default:
            return nil
        }
    }
}
*/
