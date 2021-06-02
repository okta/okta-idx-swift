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

final class ResetPasswordScenarioTests: XCTestCase {
    private var app: XCUIApplication!
    private let credentials = TestCredentials(with: .passcode)!
    private var a18nProfile: A18NProfile!
    
    private struct UsernameRecoveryPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var usernameLabel: XCUIElement { app.staticTexts["identifier.label"] }
        var usernameField: XCUIElement { app.textFields["identifier.field"] }
        var continueButton: XCUIElement { app.buttons["button.Next"] }
    }
    
    private struct RecoveryMethodPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var emailButton: XCUIElement {
            app.staticTexts.allElementsBoundByIndex.first {
                $0.identifier == "authenticator.label" && $0.label == "Email"
            } ?? app.staticTexts["Email"]
        }
        
        var continueButton: XCUIElement { app.buttons["button.Choose Method"] }
    }
    
    private struct EmailCodePage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var codeLabel: XCUIElement { app.staticTexts["passcode.label"] }
        var codeField: XCUIElement { app.textFields["passcode.field"] }
        var resendButton: XCUIElement { app.staticTexts["resend"] }
        var continueButton: XCUIElement { app.buttons["button.Password"] }
    }
    
    private struct NewPasswordPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passwordLabel: XCUIElement { app.staticTexts["passcode.label"] }
        var passwordField: XCUIElement { app.secureTextFields["passcode.field"] }
        var continueButton: XCUIElement { app.buttons["button.Next"] }
    }
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        
        let a18nAPIKey = try XCTUnwrap(ProcessInfo.processInfo.environment["A18N_API_KEY"])
        let a18nProfileID = try XCTUnwrap(ProcessInfo.processInfo.environment["A18N_PROFILE_ID"])
        
        let profileExpectation = expectation(description: "A18N profile exists.")
        
        A18NProfile.loadProfile(using: a18nAPIKey, profileId: a18nProfileID) { (profile, error) in
            self.a18nProfile = profile
            profileExpectation.fulfill()
        }
        
        wait(for: [profileExpectation], timeout: .regular)
        
        app.launchArguments = [
            "--clientId", credentials.clientId,
            "--issuer", credentials.issuerUrl,
            "--scopes", credentials.scopes,
            "--redirectUri", credentials.redirectUri,
            "--reset-user"
        ]
        
        app.launch()

        continueAfterFailure = false
        
        let clientIdLabel = app.staticTexts["clientIdLabel"]
        XCTAssertTrue(clientIdLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(clientIdLabel.label, "Client ID: \(credentials.clientId)")
    }
 
    func testResetSuccessful() throws {
        app.buttons["Sign In"].tap()
        
        let recoverButton = app.staticTexts["Recover your account"]
        XCTAssertTrue(recoverButton.waitForExistence(timeout: .regular))
        recoverButton.tap()
        
        let emailRecoveryPage = UsernameRecoveryPage(app: app)
        XCTAssertTrue(emailRecoveryPage.usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(emailRecoveryPage.usernameField.exists)
        XCTAssertTrue(emailRecoveryPage.continueButton.exists)
        
        if !emailRecoveryPage.usernameField.isFocused {
            emailRecoveryPage.usernameField.tap()
        }
        
        emailRecoveryPage.usernameField.typeText(credentials.username)
        emailRecoveryPage.continueButton.tap()
        
        
        let methodPage = RecoveryMethodPage(app: app)
        XCTAssertTrue(methodPage.emailButton.waitForExistence(timeout: .regular))
        XCTAssertTrue(methodPage.continueButton.waitForExistence(timeout: .regular))
        
        methodPage.emailButton.tap()
        methodPage.continueButton.tap()
        
        let emailCodePage = EmailCodePage(app: app)
        XCTAssertTrue(emailCodePage.codeField.waitForExistence(timeout: .regular))
        XCTAssertTrue(emailCodePage.codeLabel.exists)
        XCTAssertTrue(emailCodePage.resendButton.exists)
        XCTAssertTrue(emailCodePage.continueButton.exists)
        
        let codeExpectation = expectation(description: "Email code received.")
        var emailCode: String?
        
        let emailReceiver = EmailCodeReceiver(profile: a18nProfile)
        emailReceiver.waitForCode(timeout: .regular, pollInterval: .regular / 4) { code in
            emailCode = code
            
            if code != nil {
                codeExpectation.fulfill()
            }
        }
        
        wait(for: [codeExpectation], timeout: .regular)
        
        if !emailCodePage.codeField.isFocused {
            emailCodePage.codeField.tap()
        }
        
        emailCodePage.codeField.typeText(try XCTUnwrap(emailCode))
        emailCodePage.continueButton.tap()
        
        let passwordPage = NewPasswordPage(app: app)
        XCTAssertTrue(passwordPage.passwordField.waitForExistence(timeout: .regular))
        XCTAssertTrue(passwordPage.passwordLabel.exists)
        XCTAssertTrue(passwordPage.continueButton.exists)
        
        if !passwordPage.passwordField.isFocused {
            passwordPage.passwordField.tap()
        }
        
        passwordPage.passwordField.typeText("Abcd123\(Int.random(in: 1...1000))")
        
        passwordPage.continueButton.tap()
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(usernameLabel.staticTexts[credentials.username].exists)
    }
    
    func testResetWithIncorrectUsername() throws {
        app.buttons["Sign In"].tap()
        
        let recoverButton = app.staticTexts["Recover your account"]
        XCTAssertTrue(recoverButton.waitForExistence(timeout: .regular))
        recoverButton.tap()
        
        let emailRecoveryPage = UsernameRecoveryPage(app: app)
        XCTAssertTrue(emailRecoveryPage.usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(emailRecoveryPage.usernameField.exists)
        XCTAssertTrue(emailRecoveryPage.continueButton.exists)
        
        if !emailRecoveryPage.usernameField.isFocused {
            emailRecoveryPage.usernameField.tap()
        }
        
        let incorrectUsername = "incorrect.username"
        
        emailRecoveryPage.usernameField.typeText(incorrectUsername)
        emailRecoveryPage.continueButton.tap()
        
        XCTAssertTrue(app.staticTexts["There is no account with the Username \(incorrectUsername)."].waitForExistence(timeout: .regular))
    }
}
