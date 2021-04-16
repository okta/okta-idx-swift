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
    class ChangePassword: Request, OktaIdxAuthRemediationRequest  {
        var password: String
        
        init(password: String,
             completion: OktaIdxAuth.ResponseResult?)
        {
            self.password = password
            
            super.init(completion: completion)
        }

        func send(to implementation: OktaIdxAuth.Implementation,
                  from response: IDXClient.Response)
        {
            if let reenroll = response.remediation?[.reenrollAuthenticator] {
                let parameters = IDXClient.Remediation.Parameters()
                if let field = reenroll["credentials"]?["passcode"] {
                    parameters[field] = password
                    
                    if let (errorResponse, error) = doesFieldHaveError(implementation: implementation,
                                                                       from: reenroll,
                                                                       in: field)
                    {
                        self.recoverableError(response: errorResponse, error: error)
                        return
                    }
                }
                
                proceed(to: implementation, using: reenroll, with: parameters)
            }
            
            else {
                needsAdditionalRemediation(using: response, from: implementation)
            }
        }
        
        override func doesFieldHaveError(implementation: Implementation,
                                         from option: IDXClient.Remediation.Option,
                                         in field: IDXClient.Remediation.FormValue) -> (Response, AuthError)?
        {
            guard let message = field.messages?.first,
               let error = AuthError(from: message)
            else {
                return nil
            }
         
            var additionalInfo: [String: Any]?
            if let authenticator = option.relatesTo?.first as? IDXClient.Authenticator {
                additionalInfo = authenticator.settings as? [String: Any]
            }
            
            return (.init(status: .passwordInvalid,
                          token: nil,
                          context: implementation.client.context,
                          additionalInfo: additionalInfo),
                    error)
        }
    }
}
