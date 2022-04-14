/*
 * Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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
import AuthFoundation

extension IDXAuthenticationFlow {
    struct SuccessResponseTokenRequest {
        let httpMethod: APIRequestMethod
        let url: URL
        let accepts: APIContentType
        let bodyParameters: [String : Any]
        let clientId: String
    }

    struct RedirectURLTokenRequest {
        let openIdConfiguration: OpenIdConfiguration
        let clientId: String
        let interactionCode: String
        let pkce: PKCE
    }
}

extension IDXAuthenticationFlow.SuccessResponseTokenRequest: OAuth2TokenRequest {
    init(successResponse option: Remediation,
         clientId: String,
         context: IDXAuthenticationFlow.Context) throws
    {
        guard let method = APIRequestMethod(rawValue: option.method),
              let accepts = APIContentType(rawValue: option.accepts ?? APIContentType.json.rawValue)
        else {
            throw IDXAuthenticationFlowError.cannotCreateRequest
        }
        
        let parameters: [String:Any] = option.form.allFields.reduce(into: [:]) { partialResult, field in
            guard let name = field.name else { return }
            switch name {
            case "client_id":
                partialResult[name] = clientId
            case "code_verifier":
                partialResult[name] = context.pkce.codeVerifier
            default:
                guard let value = field.value else { return }
                partialResult[name] = value
            }
        }

        self.clientId = clientId
        self.httpMethod = method
        self.url = option.href
        self.accepts = accepts
        self.bodyParameters = parameters
    }
}

extension IDXAuthenticationFlow.RedirectURLTokenRequest: OAuth2TokenRequest {
    var httpMethod: APIRequestMethod { .post }
    var url: URL { openIdConfiguration.tokenEndpoint }
    var contentType: APIContentType? { .formEncoded }
    var acceptsType: APIContentType? { .json }
    var bodyParameters: [String : Any]? {
        [
            "client_id": clientId,
            "grant_type": "interaction_code",
            "code": interactionCode,
            "code_verifier": pkce.codeVerifier
        ]
    }
}
