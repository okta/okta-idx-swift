//
// Copyright (c) 2022-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

@testable import NativeAuthentication

#if SWIFT_PACKAGE
@testable import TestCommon
#endif

class NativeAuthenticationTests: XCTestCase {
    override func setUpWithError() throws {
    }

    func testBuilder() throws {
        var boolVar = false
        
        let form = ComponentGroup {
            Label("Sign In")
                .style(.heading)
            if boolVar {
                TextInput(label: "Username")
            }
        }
        
        print(form.components)
    }
}
