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

@resultBuilder
public struct ComponentBuilder {
    public static func buildBlock(_ components: any SignInComponent...) -> [any SignInComponent] {
        components
    }

    public static func buildBlock() -> Empty {
        .init(id: UUID().uuidString)
    }
    
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : SignInComponent {
        content
    }
    
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : SignInComponent {
        content
    }
    
//    public static func buildEither<Content>(first component: some Content) -> Content where Content : Component {
//        <#code#>
//    }
}

//extension Array: Component where Element == any Component {
//    public typealias Content = Never
//
//    func content() -> [any Component] { self }
//}
