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
    class ChangePassword: Request<Response>, OktaIdxAuthRemediationRequest  {
        let password: String
        
        init(password: String,
             completion: OktaIdxAuth.ResponseResult<Response>?)
        {
            self.password = password
            
            super.init(completion: completion)
        }

        func send(to implementation: OktaIdxAuth.Implementation,
                  from response: IDXClient.Response)
        {
            guard !hasError(implementation: implementation, in: response) else { return }

            if let reenroll = response.remediations[.reenrollAuthenticator] {
                reenroll["credentials.passcode"]?.value = password as AnyObject
                
                proceed(to: implementation, using: reenroll)
            }
            
            else {
                needsAdditionalRemediation(using: response, from: implementation)
            }
        }
        
        override func hasError(implementation: Implementation,
                               in response: IDXClient.Response) -> Bool
        {
            if let message = response.remediations[.reenrollAuthenticator]?.messages.message(for: "passcode") {
                completion?(T(status: .passwordInvalid,
                              context: implementation.context,
                              detailedResponse: response),
                            AuthError(from: message))
                return true
            }
            
            else {
                return super.hasError(implementation: implementation, in: response)
            }
        }

    }
}
