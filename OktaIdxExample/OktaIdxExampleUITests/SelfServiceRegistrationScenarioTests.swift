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
    private var a18nProfile: A18NProfile!
    
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
        
        var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"] }
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
        
        var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"] }
        var passcodeField: XCUIElement { app.secureTextFields["passcode.field"] }
    }
    
    private struct PhoneFormPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var picker: XCUIElement { app.pickers.firstMatch }
        var phoneLabel: XCUIElement { app.staticTexts["phoneNumber.label"] }
        var phoneField: XCUIElement { app.textFields["phoneNumber.field"] }
    }
    
    private struct PhonePasscodeFormPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"] }
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
        
        let a18nAPIKey = try XCTUnwrap(ProcessInfo.processInfo.environment["A18N_API_KEY"])
        let a18nProfileID = try XCTUnwrap(ProcessInfo.processInfo.environment["A18N_PROFILE_ID"])
        
        let profileExpectation = expectation(description: "Loaded profile.")
        
        A18NProfile.loadProfile(using: a18nAPIKey, profileId: a18nProfileID) { (profile, error) in
            self.a18nProfile = profile
            profileExpectation.fulfill()
        }
        
        wait(for: [profileExpectation], timeout: 15)

        app.launchArguments = [
            "--clientId", credentials.clientId,
            "--issuer", credentials.issuerUrl,
            "--redirectUri", credentials.redirectUri,
            "--reset-user"
        ]
        app.launch()

        continueAfterFailure = false
        
        XCTAssertNotNil(a18nProfile)
        XCTAssertEqual(app.staticTexts["clientIdLabel"].label, "Client ID: \(credentials.clientId)")
    }
    
    func testSignUpWithPasswordEmail() throws {
        signInButton.tap()

        try passEmailFactor(email: a18nProfile.emailAddress)
        
        XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
        skipButton.tap()
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 15.0))
        XCTAssertTrue(usernameLabel.staticTexts[credentials.username].exists)
    }
    
    func testSignUpWithPasswordEmailPhone() throws {
        signInButton.tap()

        try passEmailAndPhoneFactors(email: a18nProfile.emailAddress, phone: a18nProfile.phoneNumber)
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 15.0))
        XCTAssertTrue(usernameLabel.staticTexts[credentials.username].exists)
    }
    
    func testSignUpWithIncorrectEmail() {
        signInButton.tap()
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 15))
        signUpButton.tap()
        
        fillInInitialPage(email: "invalid@email")
        
        XCTAssertTrue(app.tables.staticTexts["'Email' must be in the form of an email address"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tables.staticTexts["Provided value for property 'Email' does not match required pattern"].waitForExistence(timeout: 5))
    }
    
    func testSignUpWithIncorrectPhone() throws {
        signInButton.tap()
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 15))
        signUpButton.tap()
        
        try passEmailFactor(email: a18nProfile.emailAddress)
        
        let factorsEntrolmentPage = FactorsEnrolmentPage(app: app)
        XCTAssertTrue(factorsEntrolmentPage.phoneLabel.waitForExistence(timeout: 5))
        factorsEntrolmentPage.phoneLabel.tap()
        
        continueButton.tap()
        
        fillInPhonePage(phone: "+380871234567")
        
        XCTAssertTrue(app.tables.staticTexts["'Email' must be in the form of an email address"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tables.staticTexts["Provided value for property 'Email' does not match required pattern"].waitForExistence(timeout: 5))
    }
    
    private func passEmailAndPhoneFactors(email: String, phone: String) throws {
        try passEmailFactor(email: email)

        let factorsEntrolmentPage = FactorsEnrolmentPage(app: app)
        XCTAssertTrue(factorsEntrolmentPage.phoneLabel.waitForExistence(timeout: 5))
        factorsEntrolmentPage.phoneLabel.tap()
        
        continueButton.tap()
        
        fillInPhonePage(phone: phone)

        let phonePasscodePage = PhonePasscodeFormPage(app: app)
        XCTAssertTrue(phonePasscodePage.passcodeLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(phonePasscodePage.passcodeField.exists)
        XCTAssertTrue(continueButton.exists)
        
        if !phonePasscodePage.passcodeField.isFocused {
            phonePasscodePage.passcodeField.tap()
        }
        
        let smsExpectation = expectation(description: "SMS code received.")
        var smsCode: String?
        
        a18nProfile.message { (message: A18NProfile.SMSMessage?, error) in
            smsCode = message?.content
            
            smsExpectation.fulfill()
        }
        
        wait(for: [smsExpectation], timeout: 15)
        
        phonePasscodePage.passcodeField.typeText(try XCTUnwrap(smsCode))
        
        continueButton.tap()
    }
    
    private func passEmailFactor(email: String) throws {
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 15))
        signUpButton.tap()
        
        fillInInitialPage(email: email)
        
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

        let codeExpectation = expectation(description: "Email code received.")
        var emailCode: String?
        
        a18nProfile.message { (message: A18NProfile.EmailMessage?, error) in
            emailCode = message?.content
            
            codeExpectation.fulfill()
        }
        
        wait(for: [codeExpectation], timeout: 15)

        emailCodePage.passcodeField.typeText(try XCTUnwrap(emailCode))
        
        continueButton.tap()
    }
    
    private func fillInInitialPage(email: String) {
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
        firstPage.emailField.typeText(email)
        
        signUpButton.tap()
    }
    
    private func fillInPhonePage(phone: String) {
        app.pickers.firstMatch.pickerWheels.element.adjust(toPickerWheelValue: "SMS")
        
        let phoneFormPage = PhoneFormPage(app: app)
        
        XCTAssertTrue(phoneFormPage.phoneLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(phoneFormPage.phoneField.exists)

        phoneFormPage.phoneField.tap()
        
        // TODO: Here Phone Number
        phoneFormPage.phoneField.typeText(phone)
        
        continueButton.tap()
    }
}
