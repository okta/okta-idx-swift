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
import OktaIdx

extension OktaIdxAuth.Implementation.Request {
    class EnrollAuthenticator: Request<Response>, OktaIdxAuthRemediationRequest  {
        let authenticator: OktaIdxAuth.Authenticator
        let parameters: [String:String]

        init(authenticator: OktaIdxAuth.Authenticator,
             with parameters: [String:String],
             completion: OktaIdxAuth.ResponseResult<Response>?)
        {
            self.authenticator = authenticator
            self.parameters = parameters
            
            super.init(completion: completion)
        }

        func send(to implementation: OktaIdxAuth.Implementation,
                  from response: IDXClient.Response? = nil)
        {
            let remediationOption = (response != nil ? response?.remediations[.enrollAuthenticator] : authenticator.remediation)
            if let remediationOption = remediationOption,
               remediationOption.type == authenticator.remediation.type
            {
                for (key, value) in parameters {
                    remediationOption[key]?.value = value as AnyObject
                }
                proceed(to: implementation, using: remediationOption)
            }
            
            else {
                needsAdditionalRemediation(using: response, from: implementation)
            }
        }
    }
}
