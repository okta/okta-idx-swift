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

extension IDXClient.Response {
    var availableAuthenticators: [OktaIdxAuth.Authenticator.AuthenticatorType] {
        var result: [OktaIdxAuth.Authenticator.AuthenticatorType] = []
        if remediations[.skip] != nil {
            result.append(.skip)
        }
        
        if let selectRemediation = remediations[.selectAuthenticatorAuthenticate] ?? remediations[.selectAuthenticatorEnroll],
           let otherOptions = selectRemediation["authenticator"]?.options
        {
            result.append(contentsOf: otherOptions.compactMap({ (option) in
                option.authenticator?.type.idxAuthType
            }))
        }
        
        return result
    }
}
