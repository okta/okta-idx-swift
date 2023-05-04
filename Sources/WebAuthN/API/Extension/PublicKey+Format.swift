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
import CryptoKit

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension CryptoKit.P256.Signing.PublicKey {
    
    func toDerRepresentation() -> Data {
        if #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *) {
            return self.derRepresentation
        } else {
            return self.derFormat()
        }
    }
    
    func toCOSEKeyEC2(alg: COSEAlgorithmIdentifier, crv: COSEKeyCurveType) -> COSEKey {
        let derRepresentationBytes = Array(self.toDerRepresentation())
        
        let x = Array(derRepresentationBytes[27..<59])
        let y = Array(derRepresentationBytes[59..<91])
        
        let key: COSEKey = COSEKeyEC2(
            alg: alg.rawValue,
            crv: crv.rawValue,
            xCoord: x,
            yCoord: y
        )
        
        return key
    }
    
    // MARK: - Private
    
    private func derFormat() -> Data {
        let x9_62HeaderECHeader = [UInt8]([
            /* sequence          */ 0x30, 0x59,
            /* |-> sequence      */ 0x30, 0x13,
            /* |---> ecPublicKey */ 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, // http://oid-info.com/get/1.2.840.10045.2.1 (ANSI X9.62 public key type)
            /* |---> prime256v1  */ 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, // http://oid-info.com/get/1.2.840.10045.3.1.7 (ANSI X9.62 named elliptic curve)
            /* |-> bit headers   */ 0x07, 0x03, 0x42, 0x00
            ])
        var result = Data()
        result.append(Data(x9_62HeaderECHeader))
        result.append(self.rawRepresentation)
        return result
    }
}
