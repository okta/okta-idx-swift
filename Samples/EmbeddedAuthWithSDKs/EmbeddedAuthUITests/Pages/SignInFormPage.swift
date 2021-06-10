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

struct SignInFormPage {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var initialSignInButton: XCUIElement { app.buttons["Sign In"] }
    
    var usernameLabel: XCUIElement { app.staticTexts["identifier.label"] }
    var usernameField: XCUIElement { app.textFields["identifier.field"] }
    
    var passwordLabel: XCUIElement { app.staticTexts["passcode.label"] }
    var passwordField: XCUIElement { app.secureTextFields["passcode.field"] }
    
    var rememberMeSwitch: XCUIElement { app.switches["Remember this device"] }
    var rememberMeLabel: XCUIElement { app.staticTexts["rememberMe.label"] }
    
    var recoveryButton: XCUIElement { app.staticTexts["Recover your account"] }
    var signInButton: XCUIElement { app.buttons["button.Sign In"] }
    var signUpButton: XCUIElement { app.buttons["Sign Up"] }
    
    func signIn(username: String, password: String) {
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: .regular))
        signInButton.tap()
        
        let signInPage = SignInFormPage(app: app)
        XCTAssertTrue(signInPage.usernameLabel.waitForExistence(timeout: .regular))
        XCTAssertTrue(signInPage.usernameField.exists)
        XCTAssertTrue(signInPage.passwordLabel.exists)
        XCTAssertTrue(signInPage.passwordField.exists)
        XCTAssertTrue(signInPage.recoveryButton.exists)
        
        signInPage.usernameField.tap()
        signInPage.usernameField.typeText(username)
        
        signInPage.passwordField.tap()
        signInPage.passwordField.typeText(password)
        
        signInPage.signInButton.tap()
    }
}