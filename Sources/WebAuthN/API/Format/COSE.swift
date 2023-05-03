//
//  COSE.swift
//  WebAuthnKit
//
//  Created by Lyo Kato on 2018/11/20.
//  Copyright © 2018 Lyo Kato. All rights reserved.
//

import Foundation

internal struct COSEKeyFieldType {
    static let kty:    Int =  1
    static let alg:    Int =  3
    static let crv:    Int = -1
    static let xCoord: Int = -2
    static let yCoord: Int = -3
    static let n:      Int = -1
    static let e:      Int = -2
}

internal enum COSEKeyCurveType: Int {
    case p256 = 1
    case p384 = 2
    case p521 = 3
    case x25519 = 4
    case x448 = 5
    case ed25519 = 6
    case ed448 = 7
}

internal struct COSEKeyType {
    static let ec2: UInt8 = 2
    static let rsa: UInt8 = 3
}

internal class COSEKeyParser {

    public static func parse(bytes: [UInt8]) -> Optional<(COSEKey, Int)>{

        let reader = CBORReader(bytes: bytes)

        guard let params = reader.readIntKeyMap() else {
            // WAKLogger.debug("<COSEKeyParser> failed to read CBOR IntKeyMap")
            return nil
        }

        let readSize = reader.getReadSize()

        guard let kty = params[Int64(COSEKeyFieldType.kty)] as? UInt8 else {
            // WAKLogger.debug("<COSEKeyParser> 'kty' not found")
            return nil
        }

        guard let alg = params[Int64(COSEKeyFieldType.alg)] as? Int else {
            // WAKLogger.debug("<COSEKeyParser> 'alg' not found")
            return nil
        }

        if kty == COSEKeyType.rsa {

            guard let n = params[Int64(COSEKeyFieldType.n)] as? [UInt8] else {
                // WAKLogger.debug("<COSEKeyParser> 'n' not found")
                return nil
            }

            if n.count != 256 {
                // WAKLogger.debug("<COSEKeyParser> 'n' should be 256 bytes")
                return nil
            }

            guard let e = params[Int64(COSEKeyFieldType.e)] as? [UInt8] else {
                // WAKLogger.debug("<COSEKeyParser> 'e' not found")
                return nil
            }

            if e.count != 3 {
                // WAKLogger.debug("<COSEKeyParser> 'e' should be 3 bytes")
                return nil
            }

            let key = COSEKeyRSA(
                alg: alg,
                n:   n,
                e:   e
            )

            return (key, readSize)

        } else if kty == COSEKeyType.ec2 {

            guard let crv = params[Int64(COSEKeyFieldType.crv)] as? Int else {
                // WAKLogger.debug("<COSEKeyParser> 'crv' not found")
                return nil
            }

            guard let x = params[Int64(COSEKeyFieldType.xCoord)] as? [UInt8] else {
                // WAKLogger.debug("<COSEKeyParser> 'xCoord' not found")
                return nil
            }

            if x.count != 32 {
                // WAKLogger.debug("<COSEKeyParser> 'xCoord' should be 32 bytes")
                return nil
            }

            guard let y = params[Int64(COSEKeyFieldType.yCoord)] as? [UInt8] else {
                // WAKLogger.debug("<COSEKeyParser> 'yCoord' not found")
                return nil
            }

            if y.count != 32 {
                // WAKLogger.debug("<COSEKeyParser> 'yCoord' should be 32 bytes")
                return nil
            }

            let key = COSEKeyEC2(
                alg:    alg,
                crv:    crv,
                xCoord: x,
                yCoord: y
            )

            return (key, readSize)

        } else {
            // WAKLogger.debug("<COSEKeyParser> unsupported 'kty': \(kty)")
            return nil
        }
    }

}

public protocol COSEKey {
    func toBytes() -> [UInt8]
}

internal struct COSEKeyRSA : COSEKey {

    var alg: Int
    var n: [UInt8] // 256 bytes
    var e: [UInt8] //   3 bytes

    public func toBytes() -> [UInt8] {

        let dic = SimpleOrderedDictionary<Int>()
        dic.addInt(COSEKeyFieldType.kty, Int64(COSEKeyType.rsa))
        dic.addInt(COSEKeyFieldType.alg, Int64(self.alg))
        dic.addBytes(COSEKeyFieldType.n, self.n)
        dic.addBytes(COSEKeyFieldType.e, self.e)

        return CBORWriter()
            .putIntKeyMap(dic)
            .getResult()
    }

}

internal struct COSEKeyEC2 : COSEKey {

    var alg: Int
    var crv: Int
    var xCoord: [UInt8] // 32 bytes
    var yCoord: [UInt8] // 32 bytes

    public func toBytes() -> [UInt8] {

        let dic = SimpleOrderedDictionary<Int>()
        dic.addInt(COSEKeyFieldType.kty, Int64(COSEKeyType.ec2))
        dic.addInt(COSEKeyFieldType.alg, Int64(self.alg))
        dic.addInt(COSEKeyFieldType.crv, Int64(self.crv))
        dic.addBytes(COSEKeyFieldType.xCoord, self.xCoord)
        dic.addBytes(COSEKeyFieldType.yCoord, self.yCoord)
        
        return CBORWriter()
            .putIntKeyMap(dic)
            .getResult()
    }
}
