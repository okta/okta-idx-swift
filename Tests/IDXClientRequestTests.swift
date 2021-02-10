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

import XCTest
@testable import OktaIdx

class IDXClientRequestTests: XCTestCase {
    let configuration = IDXClient.Configuration(issuer: "https://example.com/issuer/",
                                                clientId: "clientId",
                                                clientSecret: "clientSecret",
                                                scopes: ["all"],
                                                redirectUri: "redirect:/uri")

    func testInteractRequest() throws {
        let request = IDXClient.APIVersion1.InteractRequest(codeChallenge: "ABCEasyas123")
        let urlRequest = request.urlRequest(using: configuration)
        
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.httpMethod, "POST")

        let url = urlRequest?.url?.absoluteString
        XCTAssertEqual(url, "https://example.com/issuer/oauth2/default/v1/interact")
        
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, [
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
        ])

        let data = urlRequest?.httpBody?.urlFormEncoded()
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.keys.sorted(), ["client_id", "code_challenge", "code_challenge_method", "redirect_uri", "scope", "state"])
        XCTAssertEqual(data?["client_id"], "clientId")
        XCTAssertEqual(data?["scope"], "all")
        XCTAssertEqual(data?["code_challenge"], "ABCEasyas123")
        XCTAssertEqual(data?["code_challenge_method"], "S256")
        XCTAssertEqual(data?["redirect_uri"], "redirect:/uri")

        // Ensure state is a UUID
        let state = data?["state"]
        XCTAssertNotNil(UUID(uuidString: state!!))
    }
}
