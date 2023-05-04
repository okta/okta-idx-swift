// Copyright (c) 2023-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

internal class UUIDHelper {

    public static let zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    public static let zeroBytes: [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    public static func toBytes(_ uuid: UUID) -> [UInt8] {
        return [
            uuid.uuid.0,
            uuid.uuid.1,
            uuid.uuid.2,
            uuid.uuid.3,
            uuid.uuid.4,
            uuid.uuid.5,
            uuid.uuid.6,
            uuid.uuid.7,
            uuid.uuid.8,
            uuid.uuid.9,
            uuid.uuid.10,
            uuid.uuid.11,
            uuid.uuid.12,
            uuid.uuid.13,
            uuid.uuid.14,
            uuid.uuid.15
        ]

    }
}
