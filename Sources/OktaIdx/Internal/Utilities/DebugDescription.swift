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

import Foundation

struct DebugDescription<T: Any> {
    let object: T
    
    init(_ object: T) {
        self.object = object
    }
    
    func address() -> String where T: AnyObject {
        "\(type(of: object)): \(Unmanaged.passUnretained(object).toOpaque())"
    }
    
    func address() -> String {
        "\(type(of: object)): \(object)"
    }
    
    func unbrace(_ string: String) -> String {
        String(
            String(string.dropFirst()
            ).dropLast())
    }
    
    func brace(_ string: String) -> String {
        "<\(string)>"
    }
    
    func format<Element: CustomDebugStringConvertible>(_ list: Array<Element>, indent: Int = .zero) -> String {
        if list.isEmpty {
            return "-".indentingNewlines(by: indent)
        }
        
        return list.map { $0.debugDescription.indentingNewlines(by: indent) }.joined(separator: ";\n")
    }
}

extension String {
    func indentingNewlines(by spaceCount: Int = 4) -> String {
        let spaces = String(repeating: " ", count: spaceCount)
        let components = components(separatedBy: "\n")

        return String(components.map { "\n" + spaces + $0 }.joined().dropFirst())
    }
}
