//
// Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
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

//extension IDXClient.Remediation {
//    func extractParameters() throws -> [String:Any] {
//        return try form.formValues()
////        var result: [String:Any] = try form
////            .filter { $0.value != nil && $0.name != nil }
////            .reduce(into: [:]) { (result, formValue) in
////                guard let name = formValue.name else { throw IDXClientError.invalidParameter(name: "") }
////                result[name] = formValue.value
////            }
////
////        let allFormValues = form.reduce(into: [String:IDXClient.Remediation.Form.Field]()) { (result, value) in
////            result[value.name] = value
////        }
////
////        try params?.forEach { (key, value) in
////            guard let formValue = allFormValues[key] else {
////                throw IDXClientError.invalidParameter(name: key)
////            }
////
////            guard formValue.mutable == true else {
////                throw IDXClientError.parameterImmutable(name: key)
////            }
////
////
////            if let nestedForm = value as? IDXClient.Remediation.FormValue {
////                result[key] = try nestedForm.formValues()
////            } else {
////                result[key] = value
////            }
////        }
////
////        try allFormValues.values.filter { $0.required }.forEach {
////            /// TODO: Fix compound field support and relatesTo
////            guard result[$0.name!] != nil else {
////                throw IDXClientError.missingRequiredParameter(name: $0.name!)
////            }
////        }
////
////        return result
//    }
//}

extension IDXClient.Remediation.Form {
    func formValues() throws -> [String:Any] {
        return try fields.reduce(into: [:]) { (result, field) in
            guard let nestedResult = try field.formValues() else {
                return
            }

            if let nestedObject = nestedResult as? [String:Any] {
                result.merge(nestedObject, uniquingKeysWith: { (old, new) in
                    return new
                })
            } else if let name = field.name {
                result[name] = nestedResult
            } else {
                throw IDXClientError.invalidRequestData
            }
        }
    }
}

extension IDXClient.Remediation.Form.Field {
    func formValues() throws -> Any? {
        // Unnamed FormValues, which may contain nested options
        guard let name = name else {
            if !form.isEmpty {
                let result: [String:Any] = try form.reduce(into: [:]) { (result, formValue) in
                    let nestedObject = try formValue.formValues()

                    if let name = formValue.name {
                        result[name] = nestedObject
                    } else if let nestedObject = nestedObject as? [String:Any] {
                        result.merge(nestedObject, uniquingKeysWith: { (old, new) in
                            return new
                        })
                    } else {
                        throw IDXClientError.invalidParameter(name: formValue.name ?? "")
                    }
                }
                return result
            } else {
                return nil
            }
        }

        var result: Any? = nil
        // Named FormValues with nested forms
        if !form.isEmpty {
            let childValues: [String:Any] = try form.reduce(into: [:]) { (result, formValue) in
                guard let nestedResult = try formValue.formValues() else { return }

                if let name = formValue.name {
                    result[name] = nestedResult
                } else if let nestedObject = nestedResult as? [String:Any] {
                    result.merge(nestedObject, uniquingKeysWith: { (old, new) in
                        return new
                    })
                } else {
                    throw IDXClientError.invalidRequestData
                }
            }
            result = [name: childValues]
        }

        // Named form values that consist of multiple child options
        else if let selectedOption = selectedOption {
            let nestedResult = try selectedOption.formValues()
            result = [name: nestedResult]
        }

        // Other..
        else {
            // lots 'o stuff here
            result = value
        }

        if isRequired && result == nil {
            throw IDXClientError.missingRequiredParameter(name: name)
        }
        
        return result
    }
}
