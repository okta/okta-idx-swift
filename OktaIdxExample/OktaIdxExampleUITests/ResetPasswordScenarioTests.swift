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
    let credentials = TestCredentials(with: .passcode)!
    
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
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        
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
        
        
        let methodPage = RecoveryMethodPage(app: app)
        XCTAssertTrue(methodPage.emailButton.waitForExistence(timeout: .regular))
        XCTAssertTrue(methodPage.continueButton.waitForExistence(timeout: .regular))
        
    }
}
