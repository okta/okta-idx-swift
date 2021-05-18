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

#if SWIFT_PACKAGE
@testable import TestCommon_OktaIdx
#endif

class OktaIdxAuthImplementationMock: MockBase, OktaIdxAuthImplementation {
    var client: IDXClientAPI
    var configuration: IDXClient.Configuration?
    
    weak var delegate: OktaIdxAuthImplementationDelegate?
    
    var queue: DispatchQueue = .main

    required init(client: IDXClientAPI) {
        self.client = client
        
        super.init()
    }
    
    func client(reset: Bool, completion: @escaping (IDXClientAPI) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "reset": reset as Bool
                                          ]))
        let result = self.response(for: #function)
        completion(client)
    }
    
    func succeeded(with response: IDXClient.Response, completion: @escaping (IDXClient.Token?, Error?) -> Void) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "response": response as Any
                                          ]))
        let result = self.response(for: #function)
        completion(result?["token"] as? IDXClient.Token, result?["error"] as? Error)

    }
    
    func fail(with error: Error) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "error": error as Any
                                          ]))
    }
    
    func authenticate(username: String, password: String?, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "username": username as Any,
                                            "password": password as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    @available(OSX 10.15, *)
    @available(iOSApplicationExtension 12.0, *)
    func socialAuth(with options: OktaIdxAuth.SocialOptions, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "options": options as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    @available(OSX 10.15, *)
    @available(iOSApplicationExtension 12.0, *)
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
                                            "authenticator": type as Any
                                          ]))
        let result = self.response(for: #function)
        completion?(result?["response"] as? OktaIdxAuth.Response, result?["error"] as? Error)
    }
    
    func select(authenticator: OktaIdxAuth.Authenticator.AuthenticatorType, from idxResponse: IDXClient.Response, completion: @escaping OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>) {
        recordedCalls.append(RecordedCall(function: #function,
                                          arguments: [
                                            "authenticator": authenticator as Any,
                                            "response": idxResponse as Any
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
