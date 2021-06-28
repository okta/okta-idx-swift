//
// Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

struct PasscodeFormPage {
    private let app: XCUIApplication
    private let isSecure: Bool
    
    init(app: XCUIApplication, isSecure: Bool = false) {
        self.app = app
        self.isSecure = isSecure
    }
    
    var passcodeLabel: XCUIElement { app.staticTexts["passcode.label"] }
    var passcodeField: XCUIElement { app.textFields ["passcode.field"] }
    var securityPasscodeField: XCUIElement { app.secureTextFields["passcode.field"] }
    var resendButton: XCUIElement { app.staticTexts["resend"] }
    
    var continueButton: XCUIElement {
        app.buttons
            .allElementsBoundByIndex
            .first { $0.identifier == "button.Next" }
            ?? app.staticTexts["Continue"] // strange bug from response
        
    }
}
