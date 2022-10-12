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

//enum ResponseTransformerError: Error {
//    case cannotGenerateForm
//    case cannotGenerateSection
//}
//
//class ResponseTransformer {
//    func form(from response: Response) throws -> FormLayout {
//        try response.form()
//    }
//}
//
//extension Response {
//    func form() throws -> FormLayout {
//        let sections: [FormLayout.Section] = try remediations.compactMap { [weak self] remediation in
//            try remediation.section(from: self)
//        }
//        
//        return FormLayout(response: self,
//                          sections: sections)
//    }
//}
//
//extension Remediation {
//    func section(from response: Response?) throws -> FormLayout.Section? {
//        guard let response = response else { return nil }
//        
//        let fields: [FormLayout.Field] = try form.fields.compactMap { [weak self] field in
//            try field.field(from: response, remediation: self)
//        }.reduce([], +)
//
//        return .init(remediation: self,
//                     fields: fields,
//                     actions: [])
//    }
//}
//
//extension Remediation.Form.Field {
//    func field(from response: Response?, remediation: Remediation?) throws -> [FormLayout.Field]? {
//        guard let response = response,
//              let remediation = remediation
//        else {
//            return nil
//        }
//        
//        return nil
//    }
//}

//extension Remediation.Form.Field {
//    func remediationRow(parent: Form.Field? = nil, delegate: AnyObject & SigninRowDelegate) -> [Row] {
//        if !isMutable {
//            if label != nil {
//                // Fields that are not "visible" don't mean they shouldn't be displayed, just that they
//                return [Row(kind: .label(field: self),
//                            parent: parent,
//                            delegate: delegate)]
//            } else {
//                return []
//            }
//        }
//
//        var rows: [Row] = []
//
//        switch type {
//        case "boolean":
//            rows.append(Row(kind: .toggle(field: self),
//                            parent: parent,
//                            delegate: delegate))
//        case "object":
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
//            } else if let form = form {
//                rows.append(contentsOf: form.flatMap { nested in
//                    nested.remediationRow(parent: self, delegate: delegate)
//                })
//            }
//
//        default:
//            if let options = options {
//                rows.append(Row(kind: .select(field: self, values: options),
//                                parent: parent,
//                                delegate: delegate))
//            } else if let form = form {
//                rows.append(contentsOf: form.flatMap { formValue in
//                    formValue.remediationRow(parent: self, delegate: delegate)
//                })
//            } else {
//                rows.append(Row(kind: .text(field: self),
//                                parent: parent,
//                                delegate: delegate))
//            }
//        }
//
//        self.messages.forEach { message in
//            rows.append(Row(kind: .message(style: .message(message: message)),
//                            parent: parent,
//                            delegate: delegate))
//        }
//
//        return rows
//    }
//}

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
