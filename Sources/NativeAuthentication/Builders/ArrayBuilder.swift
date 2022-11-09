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
public struct ArrayBuilder<Element> {
    public static func buildBlock(_ elements: Element...) -> [Element] { elements }
    public static func buildBlock(_ elements: [Element]...) -> [Element] { elements.reduce([], +) }
    public static func buildPartialBlock(first: Element) -> [Element] { [first] }
    public static func buildPartialBlock(first: [Element]) -> [Element] { first }
    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }
    public static func buildLimitedAvailability(_ elements: [Element]) -> [Element] { elements }
    public static func buildArray(_ elements: [[Element]]) -> [Element] { elements.flatMap { $0 } }
    public static func buildOptional(_ element: [Element]?) -> [Element] { element ?? [] }
    public static func buildExpression(_ expression: Element) -> [Element] { [expression] }
    public static func buildExpression(_ expression: Element?) -> [Element] { [expression].compactMap { $0 } }
    public static func buildExpression(_ expression: [Element]) -> [Element] { expression }
    public static func buildBlock() -> [Element] { [] }
    public static func buildEither(first: [Element]) -> [Element] { first }
    public static func buildEither(second: [Element]) -> [Element] { second }
    public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    public static func buildPartialBlock(first: Never) -> [Element] {}
}
