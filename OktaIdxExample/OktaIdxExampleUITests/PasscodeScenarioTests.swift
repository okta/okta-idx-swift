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
        
        let credentials: TestingCredentials = try XCTUnwrap(PasswordCredentials(scenario: .regural))
        // These parameters are the same for all scenarios of Passcode feature.
        app.launchArguments = [
            "--clientId \"\(credentials.clientId)\"",
            "--issuer \"\(credentials.issuerUrl)\"",
            "--scopes \"\(credentials.scopes)\"",
            "--redirectUri \"\(credentials.redirectUri)\"",
            "--reset-user"
        ]
        
        app.launch()

        continueAfterFailure = false
        
        XCTAssertEqual(app.staticTexts["clientIdLabel"].label, "Client ID: \(credentials.clientId)")
    }

    func testSuccessfulPasscode() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .regural))
        
        signIn(username: credentials.username, password: credentials.password)
        
        // Token
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: 15.0))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }
    
    func testIncorrectUsername() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .regural))
        
        signIn(username: "incorrect.username", password: credentials.username)

        let incorrectUsernameAlert = app.alerts.staticTexts["You do not have permission to perform the requested action."]
        XCTAssertTrue(incorrectUsernameAlert.waitForExistence(timeout: 5.0))
    }

    func testIncorrectPassword() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .regural))
        
        signIn(username: credentials.username, password: "InvalidPassword")

        let incorrectPasswordLabel = app.tables.staticTexts["Authentication failed"]
        XCTAssertTrue(incorrectPasswordLabel.waitForExistence(timeout: 5.0))
    }
    
    func testNotAssignedUser() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .notAssigned))
        
        signIn(username: credentials.username, password: credentials.password)

        let notAssignedUserLabel = app.tables.staticTexts["User is not assigned to this application"]
        XCTAssertTrue(notAssignedUserLabel.waitForExistence(timeout: 5.0))
    }
    
    func testSuspendedUser() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .suspended))
        
        signIn(username: credentials.username, password: credentials.password)

        let suspendedUserLabel = app.tables.staticTexts["Authentication failed"]
        XCTAssertTrue(suspendedUserLabel.waitForExistence(timeout: 5.0))
    }
    
    func testLockedUser() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .locked))
        
        signIn(username: credentials.username, password: credentials.password)

        let lockedUserLabel = app.tables.staticTexts["Authentication failed"]
        XCTAssertTrue(lockedUserLabel.waitForExistence(timeout: 5.0))
    }
    
    func testDeactivatedUser() throws {
        let credentials = try XCTUnwrap(PasswordCredentials(scenario: .deactivated))
        
        signIn(username: credentials.username, password: credentials.password)

        let deactivatedUserLabel = app.tables.staticTexts["User is not assigned to this application"]
        XCTAssertTrue(deactivatedUserLabel.waitForExistence(timeout: 5.0))
    }
    
    private func signIn(username: String, password: String) {
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
        usernameField.typeText(username)
        
        // Password
        XCTAssertTrue(app.staticTexts["passcode.label"].waitForExistence(timeout: 5.0))
        XCTAssertEqual(app.staticTexts["passcode.label"].label, "Password")
        
        let passwordField = app.secureTextFields["passcode.field"]
        XCTAssertEqual(passwordField.value as? String, "")
        if !passwordField.isFocused {
            passwordField.tap()
        }
        
        passwordField.press(forDuration: 1.3)
        UIPasteboard.general.string = password
        passwordField.doubleTap()
        app.menuItems["Paste"].tap()
        
        sleep(1)

        app.buttons["Next"].tap()
    }
}
