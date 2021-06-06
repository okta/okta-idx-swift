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

private struct EmailFormPage {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"] }
    var passcodeField: XCUIElement { app.textFields["passcode.field"] }
}

final class EmailLoginScenarioTests: XCTestCase {
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
    
    func testLoginWithEmail() throws {
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let factorsPage = FactorsEnrollmentPage(app: app)
        XCTAssertTrue(factorsPage.emailLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(factorsPage.continueButton.exists)
        
        factorsPage.emailLabel.tap()
        factorsPage.continueButton.tap()
        
        let codePage = PasscodeFormPage(app: app)
        XCTAssertTrue(codePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(codePage.passcodeField.exists)
        
        let codeExpectation = expectation(description: "Email code received.")
        var emailCode: String?
        let emailReceiver = SMSReceiver(profile: a18nProfile)
        emailReceiver.waitForCode(timeout: .regular, pollInterval: .regular / 4) { (code) in
            emailCode = code
            
            codeExpectation.fulfill()
        }

        wait(for: [codeExpectation], timeout: .regular)
        
        codePage.passcodeField.tap()
        codePage.passcodeField.typeText(try XCTUnwrap(emailCode))
        
        codePage.continueButton.tap()
        
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: .regular))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }
    
    func testLoginWithInvalidCode() throws {
        let signInPage = SignInFormPage(app: app)
        signInPage.signIn(username: credentials.username, password: credentials.password)
        
        let factorsPage = FactorsEnrollmentPage(app: app)
        XCTAssertTrue(factorsPage.emailLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(factorsPage.continueButton.exists)
        
        factorsPage.emailLabel.tap()
        factorsPage.continueButton.tap()
        
        let codePage = PasscodeFormPage(app: app)
        XCTAssertTrue(codePage.passcodeLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(codePage.passcodeField.exists)

        codePage.passcodeField.tap()
        codePage.passcodeField.typeText("12345")
        
        codePage.continueButton.tap()
        
        XCTAssertTrue(app.staticTexts["Invalid code. Try again."].waitForExistence(timeout: .regular))
    }
}
