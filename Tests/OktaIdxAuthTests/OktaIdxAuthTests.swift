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

#if SWIFT_PACKAGE
@testable import TestCommon_OktaIdx
@testable import TestCommon_OktaIdxAuth
#endif

class OktaIdxAuthTests: XCTestCase {
    let context = IDXClient.Context(configuration: .init(issuer: "issuer",
                                                         clientId: "clientId",
                                                         clientSecret: "clientSecret",
                                                         scopes: ["all"],
                                                         redirectUri: "redirect:/uri"),
                                    state: "state",
                                    interactionHandle: "foo",
                                    codeVerifier: "bar")
    var client: OktaIdxAuth!
    var api: OktaIdxAuthImplementationMock!
    var result: (IDXClient.Token?, Error?)?
    
    override func setUpWithError() throws {
        api = OktaIdxAuthImplementationMock()
        client = OktaIdxAuth.init(with: api, queue: .main, completion: { (token, error) in
            self.result = (token, error)
        })
    }

    func testConstructors() {
        XCTAssertNotNil(api)
        // TODO: More tests to come
    }
}
