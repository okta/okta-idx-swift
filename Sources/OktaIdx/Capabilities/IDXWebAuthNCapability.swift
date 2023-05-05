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

import Foundation
import WebAuthN

extension Capability {
    /// Capability to recover an account.
    public struct WebAuthN: AuthenticatorCapability {
        public let activationData: CredentialCreationOptions?
        public let requestData: CredentialRequestOptions?

        @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
        func enroll() throws -> (Data, Data) {
            guard let activationData = activationData else {
                throw WebAuthnError.unknownError
            }
            
            let client = WebAuthnClient()
            switch client.create(origin: origin.absoluteString,
                                 options: activationData,
                                 sameOriginWithAncestors: true)
            {
            case .success(let data):
                return (Data(data.attestationObjectResult.toBytes() ?? []),
                        data.clientDataJSONResult)
            case .failure(let error):
                throw error
            }
        }
        
        @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
        func verify() throws -> (Data, Data, Data) {
            guard let requestData = requestData else {
                throw WebAuthnError.unknownError
            }
            
            let client = WebAuthnClient()
            switch client.get(origin: origin.absoluteString,
                              options: requestData,
                              sameOriginWithAncestors: true)
            {
            case .success(let data):
                return (data.authenticatorDataResult,
                        data.clientDataJSONResult,
                        data.signatureResult)
            case .failure(let error):
                throw error
            }
        }
        let origin: URL
    }
}
