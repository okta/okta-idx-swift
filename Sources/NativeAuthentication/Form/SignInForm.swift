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

#if canImport(UIKit)
import UIKit
public typealias ThemeImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias ThemeImage = NSImage
#else
public typealias ThemeImage = Void
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SignInForm {
    public enum Intent {
        case signIn, empty, loading, success, custom
    }
    
    public struct Theme {
        public var logo: Data? {
            didSet {
                guard let logo = logo else {
                    logoImage = nil
                    return
                }
                
                logoImage = image(from: logo)
            }
        }
        
        private func image(from data: Data?) -> ThemeImage? {
            guard let data = data else { return nil }
            
            #if canImport(UIKit)
            return UIImage(data: data)
            #elseif canImport(AppKit)
            return NSImage(data: data)
            #endif
        }
        
        public private(set) var logoImage: ThemeImage?
        public init(logo: Data? = nil) {
            self.logo = logo
            self.logoImage = image(from: logo)
        }
    }
    
    public var intent: Intent
    public var sections: [any SignInSection]
    public var theme: Theme?
    
    public init(intent: Intent, @ArrayBuilder<any SignInSection> content: () -> [any SignInSection]) {
        self.intent = intent
        self.sections = content()
    }

    public static let empty = SignInForm(intent: .empty) {}
    public static let loading = SignInForm(intent: .loading) {
        HeaderSection(id: "loading") {
            Loading(id: "loadingIndicator")
        }
    }
}
