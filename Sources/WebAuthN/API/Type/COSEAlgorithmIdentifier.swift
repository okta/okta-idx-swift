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

/**
 Cryptographic Algorithm Identifier
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-alg-identifier)
 - Note: [Internet Assigned Numbers Authority](https://www.iana.org/assignments/cose/cose.xhtml#algorithms)
 */
public enum COSEAlgorithmIdentifier: Int, Codable {
    case rs256 = -257
    case rs384 = -258
    case rs512 = -259
    case es256 =   -7
    case es384 =  -35
    case es512 =  -36
    case ed256 = -260
    case ed512 = -261
    case ps256 =  -37
    
    static func fromInt(_ num: Int) -> COSEAlgorithmIdentifier? {
        switch num {
        case self.rs256.rawValue:
            return self.rs256
        case self.rs384.rawValue:
            return self.rs384
        case self.rs512.rawValue:
            return self.rs512
        case self.es256.rawValue:
            return self.es256
        case self.es384.rawValue:
            return self.es384
        case self.es512.rawValue:
            return self.es512
        case self.ed256.rawValue:
            return self.ed256
        case self.ed512.rawValue:
            return self.ed512
        case self.ps256.rawValue:
            return self.ps256
        default:
            return nil
        }
    }

    public static func == (lhs: COSEAlgorithmIdentifier, rhs: COSEAlgorithmIdentifier) -> Bool {
        switch (lhs, rhs) {
        case (.es256, .es256):
            return true
        case (.es384, .es384):
            return true
        case (.es512, .es512):
            return true
        case (.rs256, .rs256):
            return true
        case (.rs384, .rs384):
            return true
        case (.rs512, .rs512):
            return true
        case (.ed256, .ed256):
            return true
        case (.ed512, .ed512):
            return true
        case (.ps256, .ps256):
            return true
        default:
            return false
        }
    }
}
