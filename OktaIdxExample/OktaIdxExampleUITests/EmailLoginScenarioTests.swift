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

final class EmailLoginScenarioTests: ScenarioTestCase {
    class override var category: Scenario.Category { .passcodeOnly }

    override class func setUp() {
        super.setUp()
        
        do {
            try scenario.createUser()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLoginWithEmail() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
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
        
        let emailCode = try scenario.receive(code: .sms)
        
        codePage.passcodeField.tap()
        codePage.passcodeField.typeText(emailCode)
        
        codePage.continueButton.tap()
        
        XCTAssertTrue(app.tables.cells["username"].waitForExistence(timeout: .regular))
        XCTAssertTrue(app.tables.cells["username"].staticTexts[credentials.username].exists)
    }
    
    func testLoginWithInvalidCode() throws {
        let credentials = try XCTUnwrap(scenario.credentials)
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
