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
    class Authenticate: Request<Response>, OktaIdxAuthRemediationRequest {
        let username: String
        let password: String?
        
        init(username: String,
             password: String?,
             completion: OktaIdxAuth.ResponseResult<Response>?)
        {
            self.username = username
            self.password = password
            
            super.init(completion: completion)
        }

        func send(to implementation: Implementation,
                  from response: IDXClient.Response)
        {
            guard !hasError(implementation: implementation, in: response) else { return }
            
            if let selectIdentify = response.remediations[.selectIdentify] {
                proceed(to: implementation, using: selectIdentify)
            }
            
            else if let identify = response.remediations[.identify] {
                identify.form["identifier"]?.value = username as AnyObject
                identify.form["credentials.passcode"]?.value = password as AnyObject
                proceed(to: implementation, using: identify)
            }
            
            else if let challengeAuthenticator = response.remediations[.challengeAuthenticator] {
                challengeAuthenticator.form["credentials.passcode"]?.value = password as AnyObject

                proceed(to: implementation, using: challengeAuthenticator)
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
            
            if response.remediations[.reenrollAuthenticator] != nil {
                completion(Response(status: .passwordExpired,
                                    context: implementation.context,
                                    detailedResponse: response),
                           nil)
            } else {
                super.needsAdditionalRemediation(using: response, from: implementation)
            }
        }
        
        override func hasError(implementation: Implementation,
                               in response: IDXClient.Response) -> Bool
        {
            if let message = response.messages.message(for: "identifier") {
                completion?(T(status: .unknown,
                              context: implementation.context,
                              detailedResponse: response),
                            AuthError(from: message))
                return true
            }
            
            else if let message = response.messages.message(for: "passcode") {
                completion?(.init(status: .passwordInvalid,
                                  context: implementation.context,
                                  detailedResponse: response),
                            AuthError.serverError(message: message.message))
                return true
            }
            
            else {
                return super.hasError(implementation: implementation, in: response)
            }
        }
    }
}
