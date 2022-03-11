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
import XCTest

/// Defines the types of properties that can be assigned to an `Remediation.Form.Field` value.
public protocol IDXFormValue {
    func isEqualTo(_ other: IDXFormValue) -> Bool
}

extension String : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? String else { return false }
        return self == other
    }
}

extension Bool : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Bool else { return false }
        return self == other
    }
}

extension Double : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Double else { return false }
        return self == other
    }
}

extension Int : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Int else { return false }
        return self == other
    }
}

extension UInt : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? UInt else { return false }
        return self == other
    }
}

extension Int8 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Int8 else { return false }
        return self == other
    }
}

extension UInt8 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? UInt8 else { return false }
        return self == other
    }
}

extension Int16 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Int16 else { return false }
        return self == other
    }
}

extension UInt16 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? UInt16 else { return false }
        return self == other
    }
}

extension Int32 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Int32 else { return false }
        return self == other
    }
}

extension UInt32 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? UInt32 else { return false }
        return self == other
    }
}

extension Int64 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Int64 else { return false }
        return self == other
    }
}

extension UInt64 : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? UInt64 else { return false }
        return self == other
    }
}

extension Float : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Float else { return false }
        return self == other
    }
}

extension Array : IDXFormValue where Element == IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? Array,
              self.count == other.count
        else { return false }
        for index in 0...self.count {
            guard self[index].isEqualTo(other[index]) else { return false }
        }
        return true
    }
}

extension Dictionary : IDXFormValue where ElementType == IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        // TODO
    }
}

@nonobjc extension NSString : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? NSString else { return false }
        return self == other
    }
}

@nonobjc extension NSDate : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? NSDate else { return false }
        return self == other
    }
}

@nonobjc extension NSData : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? NSData else { return false }
        return self == other
    }
}

@nonobjc extension NSNumber : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? NSNumber else { return false }
        return self == other
    }
}

@nonobjc extension NSArray : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? NSArray else { return false }
        return self == other
    }
}

@nonobjc extension NSDictionary : IDXFormValue {
    public func isEqualTo(_ other: IDXFormValue) -> Bool {
        guard let other = other as? NSDictionary else { return false }
        return self == other
    }
}
