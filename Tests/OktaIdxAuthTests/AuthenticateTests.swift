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

import XCTest
@testable import OktaIdx
@testable import OktaIdxAuth

class AuthenticateTests: XCTestCase {
    private typealias Authenticate = OktaIdxAuth.Implementation.Request<OktaIdxAuth.Response>.Authenticate
    private typealias TestResponse = IDXClient.Response.Test
    var api: OktaIdxAuthImplementationMock!
    
    override func setUpWithError() throws {
        let context = IDXClient.Context(configuration: .init(issuer: "issuer",
                                                             clientId: "clientId",
                                                             clientSecret: "clientSecret",
                                                             scopes: ["all"],
                                                             redirectUri: "redirect:/uri"),
                                        state: "state",
                                        interactionHandle: "foo",
                                        codeVerifier: "bar")
        api = OktaIdxAuthImplementationMock(client: IDXClientAPIMock(context: context))
        
        try super.setUpWithError()
    }
    
    func testSuccess() throws {
        api.expect(function: "succeeded(with:completion:)", arguments: [
            "token": IDXClient.Token.success
        ])

        let expect = expectation(description: "Completion")
        let request = Authenticate(username: "trillian@earth.gov", password: "password") { (token, error) in
            XCTAssertNotNil(token)
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        request.send(to: api, from: TestResponse(client: api.client, with: [ .identify, .cancel ])
                        .when(.identify, send: TestResponse(client: api.client, with: [ .challengeAuthenticator(state: .normal), .cancel ])
                                .when(.challengeAuthenticator, send: TestResponse(client: api.client, with: [ .successWithInteractionCode ]))))
        
        wait(for: [expect], timeout: 1)
    }
}
