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

public protocol SignInValueBacking: AnyObject {
    var backingValue: Any { get set }
}

public class SignInValue<ValueType>: ObservableObject {
    let backing: any SignInValueBacking
    
    public var value: ValueType {
        get { backing.backingValue as! ValueType }
        set { backing.backingValue = newValue }
    }
    
    public init(_ backing: any SignInValueBacking) {
        self.backing = backing
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SignInForm {
    public enum Intent {
        case signIn, empty, loading
    }
    
    public let intent: Intent
    public let sections: [SignInSection]
    
    public init(intent: Intent, @SectionBuilder content: () -> [SignInSection]) {
        self.init(intent: intent, sections: content())
    }

    public init(intent: Intent, sections: [SignInSection]) {
        self.intent = intent
        self.sections = sections
    }

    public static let empty = SignInForm(intent: .empty) {}
    public static let loading = SignInForm(intent: .loading) {
        SignInSection(.header, id: "loading") {
            Loading(id: "loadingIndicator")
        }
    }
}
