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

final class PasscodeScenarioTests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        
        let credentials = try XCTUnwrap(TestCredentials(with: .passcode))
        // These parameters are the same for all scenarios of Passcode feature.
        app.launchArguments = [
            "--clientId", credentials.clientId,
            "--issuer", credentials.issuerUrl,
            "--scopes", credentials.scopes,
            "--redirectUri", credentials.redirectUri,
            "--reset-user"
        ]
        
        app.launch()

        continueAfterFailure = false
        
        XCTAssertEqual(app.staticTexts["clientIdLabel"].label, "Client ID: \(credentials.clientId)")
    }

    func testSuccessfulPasscode() throws {
        let credentials = try XCTUnwrap(TestCredentials(with: .passcode))
        
        signIn(username: credentials.username, password: credentials.password)
        
        // Token
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: .testing))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }
    
    func testIncorrectUsername() throws {
        let credentials = try XCTUnwrap(TestCredentials(with: .passcode))
        
        let username = "incorrect.username@okta.com"
        
        signIn(username: username, password: credentials.username)

        let incorrectUsernameAlert = app.tables.staticTexts["There is no account with the Username \(username)."]
        XCTAssertTrue(incorrectUsernameAlert.waitForExistence(timeout: .testing))
    }

    func testIncorrectPassword() throws {
        let credentials = try XCTUnwrap(TestCredentials(with: .passcode))
        
        signIn(username: credentials.username, password: "InvalidPassword")

        let incorrectPasswordLabel = app.tables.staticTexts["Authentication failed"]
        XCTAssertTrue(incorrectPasswordLabel.waitForExistence(timeout: .testing))
    }
    
    private func signIn(username: String, password: String) {
        app.buttons["Sign In"].tap()

        // Username
        XCTAssertTrue(app.staticTexts["identifier.label"].waitForExistence(timeout: .testing))
        XCTAssertEqual(app.staticTexts["identifier.label"].label, "Username")
        XCTAssertEqual(app.staticTexts["rememberMe.label"].label, "Remember this device")
        
        let usernameField = app.textFields["identifier.field"]
        XCTAssertEqual(usernameField.value as? String, "")
        if !usernameField.isFocused {
            usernameField.tap()
        }
        usernameField.typeText(username)
        
        // Password
        XCTAssertTrue(app.staticTexts["passcode.label"].waitForExistence(timeout: .testing))
        XCTAssertEqual(app.staticTexts["passcode.label"].label, "Password")
        
        let passwordField = app.secureTextFields["passcode.field"]
        XCTAssertEqual(passwordField.value as? String, "")
        if !passwordField.isFocused {
            passwordField.tap()
        }
        
        sleep(1)
        
        passwordField.doubleTap()
        UIPasteboard.general.string = password
        app.menuItems["Paste"].tap()
        
        sleep(1)

        app.buttons["Next"].tap()
    }
}

