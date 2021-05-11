/*
 * Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation
@testable import OktaIdx
@testable import OktaIdxAuth

class MockBase {
    struct RecordedCall {
        let function: String
        let arguments: [String:Any]?
    }

    var recordedCalls: [RecordedCall] = []
    func reset() {
        recordedCalls.removeAll()
    }
    
    private(set) var expectations: [String:[String:Any]] = [:]
    func expect(function name: String, arguments: [String:Any]) {
        expectations[name] = arguments
    }
    
    func response(for name: String) -> [String:Any]? {
        return expectations.removeValue(forKey: name)
    }
}

class IDXClientAPIMock: MockBase, IDXClientAPI {
    var context: IDXClient.Context
    
    init(context: IDXClient.Context) {
        self.context = context
    }
    
    func proceed(remediation option: IDXClient.Remediation, completion: IDXClient.ResponseResult?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "remediation": option as Any,
                                          ]))
        let result = response(for: #function)
        completion?(result?["response"] as? IDXClient.Response, result?["error"] as? Error)
    }
    
    func exchangeCode(redirect url: URL, completion: IDXClient.TokenResult?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "redirect": url as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["token"] as? IDXClient.Token, result?["error"] as? Error)
    }
    
    func exchangeCode(using remediation: IDXClient.Remediation, completion: IDXClient.TokenResult?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "using": response as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["token"] as? IDXClient.Token, result?["error"] as? Error)
    }
    
    func redirectResult(for url: URL) -> IDXClient.RedirectResult {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "redirect": url as Any
                                          ]))
        
        return .authenticated
    }
    
    func revoke(token: String, type: IDXClient.Token.RevokeType, completion: @escaping (Bool, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "token": token as Any,
                                            "type": type as Any
                                          ]))
        let result = self.response(for: #function)
        completion(result?["success"] as? Bool ?? true, result?["error"] as? Error)
    }
    
}

class IDXClientAPIv1Mock: MockBase, IDXClientAPIImpl {
    var client: IDXClientAPI?
    let configuration: IDXClient.Configuration
    static var version: IDXClient.Version = .latest
    
    init(configuration: IDXClient.Configuration) {
        self.configuration = configuration
    }
    
    func start(state: String?, completion: @escaping (IDXClient.Context?, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "state": state as Any
                                          ]))
        let result = response(for: #function)
        completion(result?["context"] as? IDXClient.Context, result?["error"] as? Error)
    }
    
    func resume(completion: @escaping (IDXClient.Response?, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function, arguments: nil))
        let result = response(for: #function)
        completion(result?["response"] as? IDXClient.Response, result?["error"] as? Error)
    }
    
    func proceed(remediation option: IDXClient.Remediation, completion: @escaping (IDXClient.Response?, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "remediation": option as Any,
                                          ]))
        let result = response(for: #function)
        completion(result?["response"] as? IDXClient.Response, result?["error"] as? Error)
    }
    
    func redirectResult(for url: URL) -> IDXClient.RedirectResult {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "url": url as Any
                                          ]))
        let result = response(for: #function)
        return result?["result"] as? IDXClient.RedirectResult ?? .invalidContext
    }
    
    @objc func exchangeCode(redirect url: URL, completion: @escaping (IDXClient.Token?, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "redirect": url as Any
                                          ]))
        let result = self.response(for: #function)
        completion(result?["token"] as? IDXClient.Token, result?["error"] as? Error)
    }

    func exchangeCode(using remediation: IDXClient.Remediation, completion: @escaping (IDXClient.Token?, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "using": remediation as Any
                                          ]))
        let result = self.response(for: #function)
        completion(result?["token"] as? IDXClient.Token, result?["error"] as? Error)
    }
    
    func revoke(token: String, type: String, completion: @escaping (Bool, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "token": token as Any,
                                            "type": type as Any
                                          ]))
        let result = self.response(for: #function)
        completion(result?["success"] as? Bool ?? true, result?["error"] as? Error)
    }
}


class OktaIdxAuthImplementationMock: MockBase, OktaIdxAuthImplementation {
    weak var delegate: OktaIdxAuthImplementationDelegate?
    
    var queue: DispatchQueue = .main
    
    func authenticate(username: String, password: String?, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "username": username as Any,
                                            "password": password as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func socialAuth(with options: OktaIdxAuth.SocialOptions, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "options": options as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func socialAuth(completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [:]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func changePassword(_ password: String, from response: OktaIdxAuth.Response, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "password": password as Any,
                                            "response": response as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func recoverPassword(username: String, authenticator type: OktaIdxAuth.Authenticator.AuthenticatorType, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "username": username as Any,
                                            "type": type as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func select(authenticator: OktaIdxAuth.Authenticator.AuthenticatorType, from idxResponse: IDXClient.Response, completion: @escaping OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "authenticator": authenticator as Any,
                                            "idxResponse": idxResponse as Any
                                          ]))
        let result = self.response(for: #function)
        completion(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func verify(authenticator: OktaIdxAuth.Authenticator, with result: [String : String], completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "authenticator": authenticator as Any,
                                            "result": result as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func enroll(authenticator: OktaIdxAuth.Authenticator, with result: [String : String], completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "authenticator": authenticator as Any,
                                            "result": result as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func register(firstName: String, lastName: String, email: String, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "firstName": firstName as Any,
                                            "lastName": lastName as Any,
                                            "email": email as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func revokeTokens(token: String, type: OktaIdxAuth.TokenType, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "token": token as Any,
                                            "type": type as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
}
