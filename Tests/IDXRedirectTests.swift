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

class IDXRedirectTests: XCTestCase {

    typealias IDXRedirect = IDXClient.APIVersion1.Redirect
    
    func testRedirectWithInvalidUrl() throws {
        let redirectFromString = IDXRedirect(url: "")
        XCTAssertNil(redirectFromString)
        
        let redirectFromUrl = IDXRedirect(url: try XCTUnwrap(URL(string: "callback")))
        XCTAssertNil(redirectFromUrl)
    }
    
    func testRedirectParameters() throws {
        let redirect = try XCTUnwrap(IDXRedirect(url: "com.test:///login?state=1234&interaction_code=qwerty#_=_"))

        XCTAssertEqual(redirect.scheme, "com.test")
        XCTAssertEqual(redirect.path, "/login")
        XCTAssertEqual(redirect.state, "1234")
        XCTAssertEqual(redirect.interactionCode, "qwerty")
    }
}


