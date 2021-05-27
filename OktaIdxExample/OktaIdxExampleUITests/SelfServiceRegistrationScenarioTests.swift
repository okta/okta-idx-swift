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

class SelfServiceRegistrationScenarioTests: XCTestCase {
    private let credentials = TestCredentials(with: .mfasop)!
    private var app: XCUIApplication!
    
    private struct InitialFormPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var firstNameLabel: XCUIElement { app.staticTexts["firstName.label"] }
        var firstNameField: XCUIElement { app.textFields["firstName.field"] }
        var lastNameLabel: XCUIElement { app.staticTexts["lastName.label"] }
        var lastNameField: XCUIElement { app.textFields["lastName.field"] }
        var emailLabel: XCUIElement { app.staticTexts["email.label"] }
        var emailField: XCUIElement { app.textFields["email.field"] }
    }
    
    private struct PasswordEnrolmentPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passwordLabel: XCUIElement { app.staticTexts["Password"] }
    }
    
    private struct PasscodeFormPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"]}
        var passcodeField: XCUIElement { app.secureTextFields["passcode.field"] }
    }
    
    private struct FactorsEnrolmentPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var emailLabel: XCUIElement { app.staticTexts["Email"] }
        var phoneLabel: XCUIElement { app.staticTexts["Phone"] }
    }
    
    private struct EmailPasscodeFormPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"]}
        var passcodeField: XCUIElement { app.secureTextFields["passcode.field"] }
    }
    
    private struct PhonePasscodeFormPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"]}
        var passcodeField: XCUIElement { app.textFields["passcode.field"] }
    }
    
    private var signInButton: XCUIElement {
        app.buttons["Sign In"]
    }
    
    private var signUpButton: XCUIElement {
        app.buttons["button.Sign Up"]
    }
    
    private var continueButton: XCUIElement {
        app.buttons["button.Next"]
    }
    
    private var skipButton: XCUIElement {
        app.buttons["button.Skip"]
    }

    override func setUpWithError() throws {
        self.app = XCUIApplication()

        app.launchArguments = [
            "--clientId", credentials.clientId,
            "--issuer", credentials.issuerUrl,
            "--redirectUri", credentials.redirectUri
        ]
        app.launch()

        continueAfterFailure = false
        
        XCTAssertEqual(app.staticTexts["clientIdLabel"].label, "Client ID: \(credentials.clientId)")
    }
    
    func testSignUpPasswordEmail() {
        signInButton.tap()

        passEmailFactor()
        
        XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
        skipButton.tap()
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 15.0))
        XCTAssertTrue(usernameLabel.staticTexts[credentials.username].exists)
    }
    
    func testSignUpPasswordEmailPhone() {
        signInButton.tap()

        registerWithEmailAndPhoneFactor()
    }
    
    private func registerWithEmailAndPhoneFactor() {
        passEmailFactor()

        let factorsEntrolmentPage = FactorsEnrolmentPage(app: app)
        XCTAssertTrue(factorsEntrolmentPage.phoneLabel.waitForExistence(timeout: 5))
        factorsEntrolmentPage.phoneLabel.tap()
        
        continueButton.tap()

        let phonePasscodePage = PhonePasscodeFormPage(app: app)
        XCTAssertTrue(phonePasscodePage.passcodeLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(phonePasscodePage.passcodeField.exists)
        XCTAssertTrue(continueButton.exists)
        
        if !phonePasscodePage.passcodeField.isFocused {
            phonePasscodePage.passcodeField.tap()
        }
        
        // TODO: Here sms code
        phonePasscodePage.passcodeField.typeText("")
        
        continueButton.tap()
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 15.0))
        XCTAssertTrue(usernameLabel.staticTexts[credentials.username].exists)
    }
    
    private func passEmailFactor() {
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 15))
        signUpButton.tap()
        
        let firstPage = InitialFormPage(app: app)
        
        XCTAssertTrue(firstPage.firstNameLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(firstPage.firstNameField.exists)
        
        XCTAssertTrue(firstPage.lastNameLabel.exists)
        XCTAssertTrue(firstPage.lastNameField.exists)
        
        XCTAssertTrue(firstPage.emailLabel.exists)
        XCTAssertTrue(firstPage.emailField.exists)
        
        firstPage.firstNameField.tap()
        firstPage.firstNameField.typeText("Test")
        firstPage.lastNameField.tap()
        firstPage.lastNameField.typeText("User")
        firstPage.emailField.tap()
        firstPage.emailField.typeText("email\(Int.random(in: 10...100))@okta.com")
        
        signUpButton.tap()
        
        let secondPage = PasswordEnrolmentPage(app: app)
        XCTAssertTrue(secondPage.passwordLabel.waitForExistence(timeout: 5))
        secondPage.passwordLabel.tap()
        
        continueButton.tap()
        
        let passwordPage = PasscodeFormPage(app: app)
        XCTAssertTrue(passwordPage.passcodeLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordPage.passcodeField.exists)
        
        if !passwordPage.passcodeField.isFocused {
            passwordPage.passcodeField.tap()
        }
        
        passwordPage.passcodeField.press(forDuration: 1.3)
        UIPasteboard.general.string = "Sample123!"
        app.menuItems["Paste"].tap()
        
        sleep(1)
        
        app.buttons.allElementsBoundByIndex.first { $0.identifier == "button.Next" }?.tap()
        
        let factorEnrolmentPage = FactorsEnrolmentPage(app: app)
        XCTAssertTrue(factorEnrolmentPage.emailLabel.waitForExistence(timeout: 5))
        factorEnrolmentPage.emailLabel.tap()
        
        continueButton.tap()
        
        let emailCodePage = EmailPasscodeFormPage(app: app)
        XCTAssertTrue(emailCodePage.passcodeLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(emailCodePage.passcodeField.exists)
        
        if !emailCodePage.passcodeField.isFocused {
            emailCodePage.passcodeField.tap()
        }

        // TODO: Here email code
        emailCodePage.passcodeField.typeText("")
        
        continueButton.tap()
    }
}
