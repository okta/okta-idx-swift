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
@testable import OktaIdx
@testable import TestCommon

public extension XCTestCase {
    func decode<T>(type: T.Type, _ json: String) throws -> T where T : Decodable & JSONDecodable {
        try decode(type: type, json.data(using: .utf8)!)
    }

    func decode<T>(type: T.Type, _ json: Data) throws -> T where T : Decodable & JSONDecodable {
        try decode(type: type, decoder: T.jsonDecoder, json)
    }
}

extension TestResponse where Self : Decodable {
    static func data(from source: TestDataSource) throws -> Self {
        try data(for: URLSessionMock.self, from: source)
    }
}
