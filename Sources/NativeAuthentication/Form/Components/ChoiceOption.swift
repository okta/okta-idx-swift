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

import Foundation

public struct ChoiceGroup: SignInComponent {
    public var id: String
    public var choices: [ChoiceOption]
    
    public init(id: String, @ArrayBuilder<ChoiceOption> choices: () -> [ChoiceOption]) {
        self.id = id
        self.choices = choices()
    }
}

public struct ChoiceOption: SignInComponent, Actionable {
    public var id: String
    public var name: String?
    public var label: String
    public var action: ((any SignInComponent) -> Void)?
    
    public init(id: String, name: String? = nil, label: String) {
        self.id = id
        self.name = name
        self.label = label
    }
}
