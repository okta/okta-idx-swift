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

class PasscodeScenarioTests: XCTestCase {
    let credentials = TestCredentials(with: .passcode)

    override func setUpWithError() throws {
        try XCTSkipIf(credentials == nil)
        
        let app = XCUIApplication()
        app.launchArguments = [
            "--clientId \"\(credentials!.clientId)\"",
            "--issuer \"\(credentials!.issuerUrl)\"",
            "--scopes \"\(credentials!.scopes)\"",
            "--redirectUri \"\(credentials!.redirectUri)\"",
            "--reset-user"
        ]
        app.launch()

        continueAfterFailure = false
        
        XCTAssertEqual(app.staticTexts["clientIdLabel"].label, "Client ID: \(credentials!.clientId)")
    }

    func testSuccessfulPasscode() throws {
        let credentials = try XCTUnwrap(self.credentials)

        let app = XCUIApplication()
        app.buttons["Sign In"].tap()

        // Username
        XCTAssertTrue(app.staticTexts["identifier.label"].waitForExistence(timeout: 5.0))
        XCTAssertEqual(app.staticTexts["identifier.label"].label, "Username")
        XCTAssertEqual(app.staticTexts["rememberMe.label"].label, "Remember this device")
        
        let usernameField = app.textFields["identifier.field"]
        XCTAssertEqual(usernameField.value as? String, "")
        if !usernameField.isFocused {
            usernameField.tap()
        }
        usernameField.typeText(credentials.username)

        app.buttons["Next"].tap()
        
        // Password
        XCTAssertTrue(app.staticTexts["passcode.label"].waitForExistence(timeout: 5.0))
        XCTAssertEqual(app.staticTexts["passcode.label"].label, "Password")
        
        let passwordField = app.secureTextFields["passcode.field"]
        XCTAssertEqual(passwordField.value as? String, "")
        if !passwordField.isFocused {
            passwordField.tap()
        }
        passwordField.typeText(credentials.password)

        app.buttons["Continue"].tap()
        
        // Token
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }

    func testUnsuccessfulPasscode() throws {
        let credentials = try XCTUnwrap(self.credentials)

        let app = XCUIApplication()
        app.buttons["Sign In"].tap()

        // Username
        XCTAssertTrue(app.staticTexts["identifier.label"].waitForExistence(timeout: 5.0))
        XCTAssertEqual(app.staticTexts["identifier.label"].label, "Username")
        XCTAssertEqual(app.staticTexts["rememberMe.label"].label, "Remember this device")
        
        let usernameField = app.textFields["identifier.field"]
        XCTAssertEqual(usernameField.value as? String, "")
        if !usernameField.isFocused {
            usernameField.tap()
        }
        usernameField.typeText(credentials.username)

        app.buttons["Next"].tap()
        
        // Password
        XCTAssertTrue(app.staticTexts["passcode.label"].waitForExistence(timeout: 5.0))
        XCTAssertEqual(app.staticTexts["passcode.label"].label, "Password")
        
        let passwordField = app.secureTextFields["passcode.field"]
        XCTAssertEqual(passwordField.value as? String, "")
        if !passwordField.isFocused {
            passwordField.tap()
        }
        passwordField.typeText("InvalidPassword")

        app.buttons["Continue"].tap()

        let incorrectPasswordLabel = app.tables.staticTexts["Password is incorrect"]
        XCTAssertTrue(incorrectPasswordLabel.waitForExistence(timeout: 5.0))
        XCTAssertTrue(incorrectPasswordLabel.exists)
    }
}
