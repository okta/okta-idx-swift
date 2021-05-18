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
import OktaIdx

extension OktaIdxAuth.Implementation.Request {
    class SelectAuthenticator: Request<Response>, OktaIdxAuthRemediationRequest  {
        let type: OktaIdxAuth.Authenticator.AuthenticatorType
        let response: IDXClient.Response

        init(type: OktaIdxAuth.Authenticator.AuthenticatorType,
             response: IDXClient.Response,
             completion: OktaIdxAuth.ResponseResult<Response>?)
        {
            self.type = type
            self.response = response
            
            super.init(completion: completion)
        }

        func send(to implementation: OktaIdxAuthImplementation,
                  from response: IDXClient.Response? = nil)
        {
            var selectRemediation: IDXClient.Remediation!
            
            if type == .skip,
               let remediation = response?.remediations[.skip]
            {
                selectRemediation = remediation
            } else if let remediation = response?.remediations[.selectAuthenticatorEnroll] {
                selectRemediation = remediation
            } else if let remediation = response?.remediations[.selectAuthenticatorAuthenticate] {
                selectRemediation = remediation
            } else {
                needsAdditionalRemediation(using: response, from: implementation)
                return
            }
            
            if let option = response?.remediations[.enrollAuthenticator] ?? response?.remediations[.challengeAuthenticator]
            {
                let status: OktaIdxAuth.Status = (option.type == .enrollAuthenticator) ? .enrollAuthenticator : .verifyAuthenticator
                let authenticator = OktaIdxAuth.Authenticator.Password(implementation: implementation,
                                                                       remediation: option)
                
                let result = OktaIdxAuth.Response(with: implementation,
                                                  status: status,
                                                  availableAuthenticators: response?.availableAuthenticators ?? [],
                                                  detailedResponse: response,
                                                  authenticator: authenticator)
                completion?(result, nil)
                return
            }
            
            if type != .skip {
                if let authenticatorField = selectRemediation?["authenticator"],
                   let option = authenticatorField.options?.first(where: { (field) -> Bool in
                    guard let authenticator = field.authenticator else { return false }
                    return authenticator.type.idxAuthType == type
                   })
                {
                    authenticatorField.selectedOption = option
                } else {
                    needsAdditionalRemediation(using: response, from: implementation)
                    return
                }
            }
            
            proceed(to: implementation, using: selectRemediation)
        }
    }
}
