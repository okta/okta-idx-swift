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
    class Authenticate: Request, OktaIdxAuthRemediationRequest {
        var username: String
        var password: String?
        
        init(username: String,
             password: String?,
             completion: OktaIdxAuth.ResponseResult?)
        {
            self.username = username
            self.password = password
            
            super.init(completion: completion)
        }

        func send(to implementation: Implementation,
                  from response: IDXClient.Response)
        {
            if let selectIdentify = response.remediation?[.selectIdentify] {
                proceed(to: implementation, using: selectIdentify)
            }
            
            else if let identify = response.remediation?[.identify] {
                let parameters = IDXClient.Remediation.Parameters()
                if let field = identify["identifier"] {
                    parameters[field] = username
                }
                
                if let field = identify["credentials"]?["passcode"] {
                    parameters[field] = password
                    
                    if let (errorResponse, error) = doesFieldHaveError(implementation: implementation,
                                                                       from: identify,
                                                                       in: field)
                    {
                        self.recoverableError(response: errorResponse, error: error)
                        return
                    }
                }
                
                proceed(to: implementation, using: identify, with: parameters)
            }
            
            else if let challengeAuthenticator = response.remediation?[.challengeAuthenticator] {
                let parameters = IDXClient.Remediation.Parameters()
                if let field = challengeAuthenticator["credentials"]?["passcode"] {
                    parameters[field] = password
                    
                    if let (errorResponse, error) = doesFieldHaveError(implementation: implementation,
                                                                       from: challengeAuthenticator,
                                                                       in: field)
                    {
                        self.recoverableError(response: errorResponse, error: error)
                        return
                    }
                }
                
                proceed(to: implementation, using: challengeAuthenticator, with: parameters)
            }
            
            else {
                needsAdditionalRemediation(using: response, from: implementation)
            }
        }
        
        override func needsAdditionalRemediation(using response: IDXClient.Response, from implementation: Implementation) {
            guard let completion = completion else {
                fatalError(.unexpectedTransitiveRequest)
                return
            }
            
            if let reenroll = response.remediation?[.reenrollAuthenticator] {
                var additionalInfo: [String: Any]?
                if let authenticator = reenroll.relatesTo?.first as? IDXClient.Authenticator {
                    additionalInfo = authenticator.settings as? [String: Any]
                }
                
                completion(Response(status: .passwordExpired,
                                    token: nil,
                                    context: implementation.client.context,
                                    additionalInfo: additionalInfo),
                           nil)
            } else {
                super.needsAdditionalRemediation(using: response, from: implementation)
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
