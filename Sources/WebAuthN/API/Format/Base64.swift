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

class Base64 {
    
    static func encodeBase64(_ bytes: [UInt8]) -> String {
        return encodeBase64(Data(bytes))
    }
    
    static func encodeBase64(_ data: Data) -> String {
        return data.base64EncodedString()
    }

    static func encodeBase64URL(_ bytes: [UInt8]) -> String {
        return encodeBase64URL(Data(bytes))
    }

    static func encodeBase64URL(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

}
