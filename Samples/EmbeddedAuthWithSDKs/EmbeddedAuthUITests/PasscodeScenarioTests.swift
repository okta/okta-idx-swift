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

final class PasscodeScenarioTests: ScenarioTestCase {
    class override var category: Scenario.Category { .passcodeOnly }

    override class func setUp() {
        super.setUp()
        
        do {
            try scenario.createUser()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSuccessfulPasscode() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)

        let userInfoPage = UserInfoPage(app: app)
        userInfoPage.assert(with: credentials)
    }
    
    func testIncorrectUsername() throws {
        let credentials = try XCTUnwrap(scenario.credentials)

        let username = "incorrect.username@okta.com"
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: username, password: credentials.password)

        let incorrectUsernameAlert = app.tables.staticTexts["There is no account with the Username \(username)."]
        XCTAssertTrue(incorrectUsernameAlert.waitForExistence(timeout: .regular))
    }

    func testIncorrectPassword() throws {
        let credentials = try XCTUnwrap(scenario.credentials)

        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: "InvalidPassword")

        let incorrectPasswordLabel = app.tables.staticTexts["Authentication failed"]
        XCTAssertTrue(incorrectPasswordLabel.waitForExistence(timeout: .regular))
    }
    
    func testForgotPasswordRedirection() throws {
        let signInPage = SignInFormPage(app: app)
        XCTAssertTrue(signInPage.initialSignInButton.waitForExistence(timeout: .regular))
        signInPage.initialSignInButton.tap()
        
        XCTAssertTrue(signInPage.recoveryButton.waitForExistence(timeout: .regular))
        signInPage.recoveryButton.tap()
        
        let emailRecoveryPage = UsernameRecoveryFormPage(app: app)
        XCTAssertTrue(emailRecoveryPage.usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(emailRecoveryPage.usernameField.exists)
        XCTAssertTrue(emailRecoveryPage.continueButton.exists)
    }
}

