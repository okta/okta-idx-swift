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
    
    private struct PasswordEnrollmentPage {
        private let app: XCUIApplication
        
        init(app: XCUIApplication) {
            self.app = app
        }
        
        var passwordLabel: XCUIElement { app.staticTexts["Password"] }
    }
    
    private var signInButton: XCUIElement {
        app.buttons["Sign In"]
    }
    
    private var signUpButton: XCUIElement {
        app.buttons["button.Sign Up"]
    }
    
    private var continueButton: XCUIElement {
        // There're two buttons with the same identifier
        app.buttons.allElementsBoundByIndex.first { $0.identifier == "button.Next" } ?? app.buttons["button.Next"]
    }
    
    private var skipButton: XCUIElement {
        app.buttons["button.Skip"]
    }

    override func setUpWithError() throws {
        self.app = XCUIApplication()
        
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
        
        XCTAssertTrue(skipButton.waitForExistence(timeout: .regular))
        skipButton.tap()
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(usernameLabel.staticTexts[a18nProfile.emailAddress].exists)
    }
    
    func testSignUpWithPasswordEmailPhone() throws {
        signInButton.tap()

        try passEmailAndPhoneFactors(email: a18nProfile.emailAddress, phone: a18nProfile.phoneNumber)
        
        let usernameLabel = app.tables.cells["username"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(usernameLabel.staticTexts[credentials.username].exists)
    }
    
    func testSignUpWithIncorrectEmail() {
        signInButton.tap()
        XCTAssertTrue(signUpButton.waitForExistence(timeout: .regular))
        signUpButton.tap()
        
        fillInInitialPage(email: "invalid@email")
        
        XCTAssertTrue(app.tables.staticTexts["'Email' must be in the form of an email address"].waitForExistence(timeout: .regular))
        XCTAssertTrue(app.tables.staticTexts["Provided value for property 'Email' does not match required pattern"].waitForExistence(timeout: .minimal))
    }
    
    func testSignUpWithIncorrectPhone() throws {
        signInButton.tap()
        
        try passEmailFactor(email: a18nProfile.emailAddress)
        
        fillInPhonePage(phone: "1230871234567")
        
        XCTAssertTrue(app.tables.staticTexts["Unable to initiate factor enrollment: Invalid Phone Number."].waitForExistence(timeout: .regular))
    }
    
    private func passEmailAndPhoneFactors(email: String, phone: String) throws {
        try passEmailFactor(email: email)
        
        fillInPhonePage(phone: phone)

        let phonePasscodePage = PasscodeFormPage(app: app)
        XCTAssertTrue(phonePasscodePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(phonePasscodePage.passcodeField.exists)
        XCTAssertTrue(phonePasscodePage.continueButton.exists)
        
        if !phonePasscodePage.passcodeField.isFocused {
            phonePasscodePage.passcodeField.tap()
        }
        
        let smsExpectation = expectation(description: "SMS code received.")
        var smsCode: String?
        
        let smsReceiver = SMSReceiver(profile: a18nProfile)
        smsReceiver.waitForCode(timeout: .regular, pollInterval: .regular / 4) { (code) in
            smsCode = code
            
            smsExpectation.fulfill()
        }
        
        wait(for: [smsExpectation], timeout: .regular)
        
        phonePasscodePage.passcodeField.typeText(try XCTUnwrap(smsCode))
        
        continueButton.tap()
    }
    
    private func passEmailFactor(email: String) throws {
        XCTAssertTrue(signUpButton.waitForExistence(timeout: .regular))
        signUpButton.tap()
        
        fillInInitialPage(email: email)
        
        let passwordEnrollmentPage = PasswordEnrollmentPage(app: app)
        XCTAssertTrue(passwordEnrollmentPage.passwordLabel.waitForExistence(timeout: .regular))
        passwordEnrollmentPage.passwordLabel.tap()
        
        continueButton.tap()
        
        let passwordPage = PasscodeFormPage(app: app)
        XCTAssertTrue(passwordPage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(passwordPage.passcodeField.exists)
        
        if !passwordPage.passcodeField.isFocused {
            passwordPage.passcodeField.tap()
        }
        
        passwordPage.passcodeField.press(forDuration: 1.3)
        UIPasteboard.general.string = "Sample123!"
        app.menuItems["Paste"].tap()
        
        Thread.sleep(forTimeInterval: 1)
        
        continueButton.tap()
        
        let factorEnrolmentPage = FactorsEnrollmentPage(app: app)
        XCTAssertTrue(factorEnrolmentPage.emailLabel.waitForExistence(timeout: .regular))
        factorEnrolmentPage.emailLabel.tap()
        factorEnrolmentPage.continueButton.tap()
        
        let codePage = PasscodeFormPage(app: app)
        XCTAssertTrue(codePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(codePage.passcodeField.exists)
        
        if !codePage.passcodeField.isFocused {
            codePage.passcodeField.tap()
        }

        let codeExpectation = expectation(description: "Email code received.")
        var emailCode: String?
        
        let emailReceiver = EmailCodeReceiver(profile: a18nProfile)
        emailReceiver.waitForCode(timeout: .regular, pollInterval: .regular / 4) { code in
            emailCode = code
            
            codeExpectation.fulfill()
        }
        
        wait(for: [codeExpectation], timeout: .regular)

        codePage.passcodeField.typeText(try XCTUnwrap(emailCode))
        codePage.continueButton.tap()
        
        // Sometimes tests are very quick. And there's a strange bug after Continue button pressed.
        // UI is updated faster than the events delivered
        Thread.sleep(forTimeInterval: 2)
    }
    
    private func fillInInitialPage(email: String) {
        let registrationPage = RegistrationFormPage(app: app)
        
        XCTAssertTrue(registrationPage.firstNameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(registrationPage.firstNameField.exists)
        
        XCTAssertTrue(registrationPage.lastNameLabel.exists)
        XCTAssertTrue(registrationPage.lastNameField.exists)
        
        XCTAssertTrue(registrationPage.emailLabel.exists)
        XCTAssertTrue(registrationPage.emailField.exists)
        
        registrationPage.firstNameField.tap()
        registrationPage.firstNameField.typeText("Test")
        registrationPage.lastNameField.tap()
        registrationPage.lastNameField.typeText("User")
        registrationPage.emailField.tap()
        registrationPage.emailField.typeText(email)
        
        signUpButton.tap()
    }
    
    private func fillInPhonePage(phone: String) {
        let factorsPage = FactorsEnrollmentPage(app: app)
        XCTAssertTrue(factorsPage.phoneLabel.waitForExistence(timeout: .regular))
        factorsPage.phoneLabel.tap()
        
        XCTAssertTrue(factorsPage.phonePicker.waitForExistence(timeout: .regular))
        factorsPage.phonePicker.pickerWheels.element.adjust(toPickerWheelValue: "SMS")
        
        let phoneFormPage = PhoneFormPage(app: app)

        XCTAssertTrue(phoneFormPage.phoneField.waitForExistence(timeout: .regular))
        XCTAssertTrue(phoneFormPage.phoneField.waitForExistence(timeout: .regular))
        
        if !phoneFormPage.phoneField.isFocused {
            phoneFormPage.phoneField.tap()
        }
        
        phoneFormPage.phoneField.typeText(phone)
        
        continueButton.tap()
    }
}
