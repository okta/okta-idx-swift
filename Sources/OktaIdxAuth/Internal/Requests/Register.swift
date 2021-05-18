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
    class Register: Request<Response>, OktaIdxAuthRemediationRequest {
        let firstName: String
        let lastName: String
        let email: String
        
        init(firstName: String,
             lastName: String,
             email: String,
             completion: OktaIdxAuth.ResponseResult<Response>?)
        {
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            
            super.init(completion: completion)
        }

        func send(to implementation: OktaIdxAuthImplementation,
                  from response: IDXClient.Response? = nil)
        {
            if let selectEnrollProfile = response?.remediations[.selectEnrollProfile] {
                proceed(to: implementation, using: selectEnrollProfile)
            }

            else if let enrollProfile = response?.remediations[.enrollProfile] {
                guard let firstNameField = enrollProfile["userProfile.firstName"],
                      let lastNameField = enrollProfile["userProfile.lastName"],
                      let emailField = enrollProfile["userProfile.email"]
                else {
                    fatalError(AuthError.missingExpectedFormField)
                    return
                }

                firstNameField.value = firstName as AnyObject
                lastNameField.value = lastName as AnyObject
                emailField.value = email as AnyObject

                proceed(to: implementation, using: enrollProfile)
            }

            else {
                needsAdditionalRemediation(using: response, from: implementation)
            }
        }
    }
}
