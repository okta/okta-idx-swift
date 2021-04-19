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
    class VerifyAuthenticator: Request<Response>, OktaIdxAuthRemediationRequest {
        var code: String
        
        init(with code: String, completion: @escaping (OktaIdxAuth.Response?, Error?) -> Void) {
            self.code = code
            
            super.init(completion: completion)
        }
        
        func send(to implementation: OktaIdxAuth.Implementation, from response: IDXClient.Response) {
            
        }
    }
}
