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

import XCTest
@testable import WebAuthN

#if SWIFT_PACKAGE
@testable import TestCommon
#endif

class ModelTests: XCTestCase {
    func testWebAuthNAuthenticator() throws {
        let obj = try decode(type: PublicKeyCredentialCreationOptions.self, """
        {
           "attestation": "direct",
           "authenticatorSelection": {
              "requireResidentKey": false,
              "userVerification": "preferred"
           },
           "challenge": "juOAXSl9SGM5GldwuCJuJcLcwM7FAEkU",
           "excludeCredentials": [],
           "pubKeyCredParams": [
              {
                 "alg": -7,
                 "type": "public-key"
              },
              {
                 "alg": -257,
                 "type": "public-key"
              }
           ],
           "rp": {
              "name": "example"
           },
           "u2fParams": {
              "appid": "https://example.com"
           },
           "user": {
              "displayName": "Example User",
              "id": "0ZczewGCFPlxNYYcLq5i",
              "name": "user@example.com"
           }
        }
        """)
        
        XCTAssertEqual(obj.rp.name, "example")
        XCTAssertEqual(obj.user.displayName, "Example User")
    }
}
