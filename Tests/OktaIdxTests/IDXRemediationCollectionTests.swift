//
// Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

#if SWIFT_PACKAGE
@testable import TestCommon
#endif

class IDXRemediationCollectionTests: XCTestCase {
    let clientMock = IDXClientAPIMock(context: .init(configuration: .init(issuer: "https://example.com",
                                                                          clientId: "Bar",
                                                                          clientSecret: nil,
                                                                          scopes: ["scope"],
                                                                          redirectUri: "redirect:/"),
                                                     state: "state",
                                                     interactionHandle: "handle",
                                                     codeVerifier: "verifier"))

    func testIdentifySubclass() throws {
        let response = try IDXClient.Response(client: clientMock,
                                              v1: .data(from: .file("introspect-response")))
        let identify = try XCTUnwrap(response.remediations.identify)
        XCTAssertTrue(identify.isMember(of: IDXClient.Remediation.Identify.self))
        XCTAssertEqual(response.remediations[.identify], identify)
        XCTAssertEqual(identify.identifierField.label, "Username")
        XCTAssertEqual(identify.rememberMeField.label, "Remember this device")
        XCTAssertNil(identify.passwordField)
    }

    func testIdentifyWithPasswordSubclass() throws {
        let response = try IDXClient.Response(client: clientMock,
                                              v1: .data(from: .file("identify-single-form-response")))
        let identify = try XCTUnwrap(response.remediations.identify)
        XCTAssertTrue(identify.isMember(of: IDXClient.Remediation.Identify.self))
        XCTAssertEqual(response.remediations[.identify], identify)
        XCTAssertEqual(identify.identifierField.label, "Username")
        XCTAssertEqual(identify.rememberMeField.label, "Remember this device")
        XCTAssertEqual(identify.passwordField?.label, "Password")
    }

    func testChallengeIdentifierSubclass() throws {
        let response = try IDXClient.Response(client: clientMock,
                                              v1: .data(from: .file("challenge-response")))
        let challenge = try XCTUnwrap(response.remediations.challengeAuthenticator)
        XCTAssertTrue(challenge.isMember(of: IDXClient.Remediation.Challenge.self))
        XCTAssertEqual(response.remediations[.challengeAuthenticator], challenge)
        XCTAssertEqual(challenge.passcodeField.label, "Password")
    }

    func testSocialAuthSubclass() throws {
        let response = try IDXClient.Response(client: clientMock,
                                              v1: .data(from: .file("02-introspect-response",
                                                                    folder: "IdP")))
        let socialAuth = try XCTUnwrap(response.remediations.redirectIdp[.facebook])
        XCTAssertTrue(socialAuth.isMember(of: IDXClient.Remediation.SocialAuth.self))
        XCTAssertEqual(response.remediations[.redirectIdp], socialAuth)
        XCTAssertEqual(socialAuth.service, .facebook)
    }

    func testSocialAuthByNameSubclass() throws {
        let response = try IDXClient.Response(client: clientMock,
                                              v1: .data(from: .file("02-introspect-response",
                                                                    folder: "IdP")))
        let socialAuth = try XCTUnwrap(response.remediations.redirectIdpByName["FACEBOOK"])
        XCTAssertTrue(socialAuth.isMember(of: IDXClient.Remediation.SocialAuth.self))
        XCTAssertEqual(response.remediations[.redirectIdp], socialAuth)
        XCTAssertEqual(socialAuth.service, .facebook)
    }
}
