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
    var api: OktaIdxAuthImplementationMock!
    var idxResponse: IDXClient.Response!
    var idxRemediation: IDXClient.Remediation!
    var idxClient = IDXClientAPIMock(context: .init(configuration: .init(issuer: "issuer",
                                                                         clientId: "clientId",
                                                                         clientSecret: "clientSecret",
                                                                         scopes: ["all"],
                                                                         redirectUri: "redirect://uri"),
                                                    state: "stateHandle",
                                                    interactionHandle: "interactionHandle",
                                                    codeVerifier: "codeVerifier"))

    override func setUpWithError() throws {
        api = OktaIdxAuthImplementationMock(client: IDXClientAPIMock(context: context))

        idxRemediation = IDXClient.Remediation(client: idxClient,
                                                     name: "cancel",
                                                     method: "GET",
                                                     href: URL(string: "some://url")!,
                                                     accepts: "application/json",
                                                     form: IDXClient.Remediation.Form(fields: [
                                                        IDXClient.Remediation.Form.Field(name: "foo",
                                                                                         visible: false,
                                                                                         mutable: true,
                                                                                         required: false,
                                                                                         secret: false)
                                                     ])!,
                                                     refresh: nil,
                                                     relatesTo: nil)

        idxResponse = IDXClient.Response(client: idxClient,
                                          expiresAt: Date(),
                                          intent: .login,
                                          authenticators: .init(authenticators: nil),
                                          remediations: .init(remediations: [idxRemediation]),
                                          successRemediationOption: nil,
                                          messages: .init(messages: nil),
                                          app: nil,
                                          user: nil)
    }

    func wait(timeout: TimeInterval = 1,
              _ block: @escaping (XCTestExpectation) -> Void)
    {
        let expect = expectation(description: "authenticate")
        block(expect)
        wait(for: [ expect ], timeout: 1)
    }
    
    func testConstructors() {
        var client = OktaIdxAuth(with: context) { (_, _) in}
        XCTAssertNotNil(client)
        XCTAssertEqual(client.context, context)
        
        client = OktaIdxAuth(issuer: "issuer", clientId: "clientId", clientSecret: "clientSecret", scopes: ["all"], redirectUri: "redirect:/uri", completion: { (_, _) in})
        XCTAssertNotNil(client)
        XCTAssertNil(client.context)
    }
    
    func testClientApiDelegation() throws {
        let client = OktaIdxAuth.init(with: api, queue: .main) { _,_ in }
        var call: MockBase.RecordedCall?

        // authenticate
        wait { expectation in
            client.authenticate(username: "zaphod@galaxy.gov", password: "password") { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "authenticate(username:password:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["username"] as? String, "zaphod@galaxy.gov")
        XCTAssertEqual(call?.arguments?["password"] as? String, "password")
        api.reset()

        // socialAuth
        wait { expectation in
            client.socialAuth { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "socialAuth(completion:)")
        XCTAssertEqual(call?.arguments?.count, 0)
        api.reset()

        // recoverPassword
        wait { expectation in
            client.recoverPassword(username: "adent@earth.org", authenticator: .email) { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "recoverPassword(username:authenticator:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["username"] as? String, "adent@earth.org")
        XCTAssertEqual(call?.arguments?["authenticator"] as? OktaIdxAuth.Authenticator.AuthenticatorType,
                       .email)
        api.reset()

        // register
        wait { expectation in
            client.register(firstName: "Arthur", lastName: "Dent", email: "adent@earth.org") { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "register(firstName:lastName:email:completion:)")
        XCTAssertEqual(call?.arguments?.count, 3)
        XCTAssertEqual(call?.arguments?["firstName"] as? String, "Arthur")
        XCTAssertEqual(call?.arguments?["lastName"] as? String, "Dent")
        XCTAssertEqual(call?.arguments?["email"] as? String, "adent@earth.org")
        api.reset()

        // revokeTokens
        wait { expectation in
            client.revokeTokens(token: "tokenId", type: .accessAndRefreshToken) { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "revokeTokens(token:type:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["token"] as? String, "tokenId")
        XCTAssertEqual(call?.arguments?["type"] as? OktaIdxAuth.TokenType,
                       .accessAndRefreshToken)
        api.reset()
    }
    
    func testResponseApiDelegation() throws {
        let response = OktaIdxAuth.Response(with: api,
                                            status: .success,
                                            availableAuthenticators: [],
                                            detailedResponse: idxResponse,
                                            authenticator: nil)
        var call: MockBase.RecordedCall?

        // changePassword
        wait { expectation in
            response.change(password: "newPassword") { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "changePassword(_:from:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["password"] as? String, "newPassword")
        XCTAssertEqual(call?.arguments?["response"] as? OktaIdxAuth.Response, response)
        api.reset()

        // select
        wait { expectation in
            response.select(authenticator: .email) { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "select(authenticator:from:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["authenticator"] as? OktaIdxAuth.Authenticator.AuthenticatorType, .email)
        XCTAssertEqual(call?.arguments?["response"] as? IDXClient.Response, idxResponse)
        api.reset()
    }

    func testAuthenticatorApiDelegation() throws {
        let authenticator = OktaIdxAuth.Authenticator(implementation: api,
                                                      remediation: idxRemediation,
                                                      type: .email)
        var call: MockBase.RecordedCall?

        // verify
        wait { expectation in
            authenticator.verify(with: "123456") { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "verify(authenticator:with:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["authenticator"] as? OktaIdxAuth.Authenticator, authenticator)
        XCTAssertEqual(call?.arguments?["result"] as? [String:String], [
            "credentials.passcode": "123456"
        ])
        api.reset()

        // enroll
        wait { expectation in
            authenticator.enroll(using: ["code": "123456"]) { _,_ in
                expectation.fulfill()
            }
        }
        call = api.recordedCalls.last
        XCTAssertEqual(call?.function, "enroll(authenticator:with:completion:)")
        XCTAssertEqual(call?.arguments?.count, 2)
        XCTAssertEqual(call?.arguments?["authenticator"] as? OktaIdxAuth.Authenticator, authenticator)
        XCTAssertEqual(call?.arguments?["result"] as? [String:String], [
            "code": "123456"
        ])
        api.reset()
    }
}
