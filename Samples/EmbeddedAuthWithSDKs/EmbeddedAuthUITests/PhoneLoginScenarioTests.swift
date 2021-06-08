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

final class PhoneLoginScenarioTests: ScenarioTestCase {
    class override var category: Scenario.Category { .passcodeOnly }
    
    override func setUp() {
        super.setUp()
        
        try? scenario.resetMessages(.sms)
        
        do {
            try scenario.createUser(groups: [.mfa, .phoneEnrollment])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try scenario.deleteUser()
    }
    
    func testEnrollWithSMS() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let factorsPage = FactorsEnrollmentPage(app: app)
        
        XCTAssertTrue(factorsPage.phoneLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(factorsPage.continueButton.exists)
        
        factorsPage.phoneLabel.tap()
        
        XCTAssertTrue(factorsPage.phonePicker.waitForExistence(timeout: .minimal))
        factorsPage.selectPickerWheel(.sms)
        
        XCTAssertTrue(factorsPage.phoneNumberLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(factorsPage.phoneNumberField.exists)
        
        factorsPage.phoneNumberField.tap()
        
        factorsPage.phoneNumberField.typeText(try XCTUnwrap(scenario.profile?.phoneNumber))
        
        factorsPage.continueButton.tap()
        
        let passcodePage = PasscodeFormPage(app: app)
        XCTAssertTrue(passcodePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(passcodePage.passcodeField.exists)
        XCTAssertTrue(passcodePage.resendButton.exists)
        
        let smsCode = try scenario.receive(code: .sms)
        
        passcodePage.passcodeField.tap()
        passcodePage.passcodeField.typeText(smsCode)
        
        passcodePage.continueButton.tap()
        
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: .regular))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }
    
    func testEnrollWithInvalidPhone() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let factorsPage = FactorsEnrollmentPage(app: app)
        
        XCTAssertTrue(factorsPage.phoneLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(factorsPage.continueButton.exists)
        
        factorsPage.phoneLabel.tap()
        
        XCTAssertTrue(factorsPage.phonePicker.waitForExistence(timeout: .minimal))
        factorsPage.selectPickerWheel(.sms)
        
        
        XCTAssertTrue(factorsPage.phoneNumberLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(factorsPage.phoneNumberField.exists)
        
        factorsPage.phoneNumberField.tap()
        factorsPage.phoneNumberField.typeText("+123456789")
        factorsPage.continueButton.tap()
        
        XCTAssertTrue(app.staticTexts["Unable to initiate factor enrollment: Invalid Phone Number."].waitForExistence(timeout: .regular))
    }
    
    func testLoginWithSMS() throws {
        try testEnrollWithSMS()
        
        app.terminate()
        app.launch()
        
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let factorsPage = FactorsEnrollmentPage(app: app)
        
        XCTAssertTrue(factorsPage.phonePicker.waitForExistence(timeout: .minimal))
        factorsPage.selectPickerWheel(.sms)
        
        // Before receiving a code, we must reset all messages.
        try scenario.resetMessages(.sms)
        
        factorsPage.continueButton.tap()
        
        let passcodePage = PasscodeFormPage(app: app)
        XCTAssertTrue(passcodePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(passcodePage.passcodeField.exists)
        XCTAssertTrue(passcodePage.resendButton.exists)
        
        let smsCode = try scenario.receive(code: .sms)
        
        passcodePage.passcodeField.tap()
        passcodePage.passcodeField.typeText(smsCode)
        
        passcodePage.continueButton.tap()
        
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: .regular))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }
    
    func testLoginWithInvalidCode() throws {
        try testEnrollWithSMS()
        
        app.terminate()
        app.launch()
        
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let factorsPage = FactorsEnrollmentPage(app: app)
        XCTAssertTrue(factorsPage.phonePicker.waitForExistence(timeout: .minimal))
        factorsPage.selectPickerWheel(.sms)
        
        factorsPage.continueButton.tap()
        
        let passcodePage = PasscodeFormPage(app: app)
        XCTAssertTrue(passcodePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(passcodePage.passcodeField.exists)
        XCTAssertTrue(passcodePage.resendButton.exists)
        
        passcodePage.passcodeField.tap()
        passcodePage.passcodeField.typeText("12345")
        
        passcodePage.continueButton.tap()
        
        XCTAssertTrue(app.staticTexts["Invalid code. Try again."].waitForExistence(timeout: .regular))
    }
}
