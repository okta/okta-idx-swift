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

    override class func setUp() {
        super.setUp()
        
        do {
            try scenario.createUser()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLoginWithSMS() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let isUserEnrolled = passFactorsEnrollment(phoneNumber: try XCTUnwrap(scenario.profile?.phoneNumber))
        
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
        
        if !isUserEnrolled {
            try testLoginWithSMS()
        }
    }
    
    func testLoginWithInvalidCode() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)

        _ = passFactorsEnrollment(phoneNumber: try XCTUnwrap(scenario.profile?.phoneNumber))
        
        let passcodePage = PasscodeFormPage(app: app)
        XCTAssertTrue(passcodePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(passcodePage.passcodeField.exists)
        XCTAssertTrue(passcodePage.resendButton.exists)
        
        passcodePage.passcodeField.tap()
        passcodePage.passcodeField.typeText("12345")
        
        passcodePage.continueButton.tap()
        
        XCTAssertTrue(app.staticTexts["Invalid code. Try again."].waitForExistence(timeout: .regular))
    }
    
    private func passFactorsEnrollment(phoneNumber: String) -> Bool {
        let factorsPage = FactorsEnrollmentPage(app: app)
        let isUserEnrolled = factorsPage.isUserPhoneEnrolled

        if !isUserEnrolled {
            XCTAssertTrue(factorsPage.phoneLabel.waitForExistence(timeout: .regular))
            XCTAssertTrue(factorsPage.continueButton.exists)
            
            factorsPage.phoneLabel.tap()
        }
        
        XCTAssertTrue(factorsPage.phonePicker.waitForExistence(timeout: .minimal))
        factorsPage.phonePicker.pickerWheels.firstMatch.adjust(toPickerWheelValue: "SMS")
        
        if !isUserEnrolled {
            XCTAssertTrue(factorsPage.phoneNumberLabel.waitForExistence(timeout: .regular))
            XCTAssertTrue(factorsPage.phoneNumberField.exists)
            
            factorsPage.phoneNumberField.tap()
            
            factorsPage.phoneNumberField.typeText("+123456789")
            factorsPage.continueButton.tap()
            
            XCTAssertTrue(app.staticTexts["Unable to initiate factor enrollment: Invalid Phone Number"].waitForExistence(timeout: .regular))
            
            factorsPage.phoneNumberField.tap()
            factorsPage.phoneNumberField.clearText()
            
            factorsPage.phoneNumberField.typeText(phoneNumber)
        }
        
        factorsPage.continueButton.tap()
        
        return isUserEnrolled
    }
}
