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

final class PhoneLoginScenarioTests: XCTestCase {
    private let credentials = TestCredentials(with: .passcode)!
    private var app: XCUIApplication!
    private var a18nProfile: A18NProfile!

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
    
    func testLoginWithSMS() throws {
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let isUserEnrolled = passFactorsEnrollment(phoneNumber: a18nProfile.phoneNumber)
        
        let passcodePage = PasscodeFormPage(app: app)
        XCTAssertTrue(passcodePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(passcodePage.passcodeField.exists)
        XCTAssertTrue(passcodePage.resendButton.exists)
        
        let codeExpectation = expectation(description: "SMS code received.")
        var smsCode: String?
        let smsReceiver = SMSReceiver(profile: a18nProfile)
        smsReceiver.waitForCode(timeout: .regular, pollInterval: .regular / 4) { (code) in
            smsCode = code
            
            codeExpectation.fulfill()
        }

        wait(for: [codeExpectation], timeout: .regular)
        
        passcodePage.passcodeField.tap()
        passcodePage.passcodeField.typeText(try XCTUnwrap(smsCode))
        
        passcodePage.continueButton.tap()
        
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: .regular))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
        
        if !isUserEnrolled {
            try testLoginWithSMS()
        }
    }
    
    func testLoginWithInvalidCode() throws {
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)

        _ = passFactorsEnrollment(phoneNumber: a18nProfile.phoneNumber)
        
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
