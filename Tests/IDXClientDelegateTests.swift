//
//  IDXClientDelegateTests.swift
//  okta-idx-ios-tests
//
//  Created by Mike Nachbaur on 2021-02-04.
//

import XCTest
@testable import OktaIdx

class IDXClientDelegateTests: XCTestCase {
    let configuration = IDXClient.Configuration(issuer: "issuer",
                                                clientId: "clientId",
                                                clientSecret: "clientSecret",
                                                scopes: ["all"],
                                                redirectUri: "redirect:/uri")
    var client: IDXClient!
    var api: IDXClientAPIv1Mock!
    var remediationOption: IDXClient.Remediation.Option!
    var response: IDXClient.Response!
    var token: IDXClient.Token!
    let delegate = DelegateRecorder()
    let error = IDXClientError.cannotCreateRequest
    
    @inlinable
    func waitFor(block: @escaping (XCTestExpectation)->Void) {
        let expect = expectation(description: "Waiting")
        DispatchQueue.global().async {
            block(expect)
        }
        wait(for: [ expect ], timeout: 1)
    }


    override func setUpWithError() throws {
        api = IDXClientAPIv1Mock(configuration: configuration)
        client = IDXClient(configuration: configuration,
                           context: nil,
                           api: api,
                           queue: DispatchQueue.main)
        client.delegate = delegate
        
        remediationOption = IDXClient.Remediation.Option(api: api,
                                                        rel: ["foo"],
                                                        name: "name",
                                                        method: "GET",
                                                        href: URL(string: "some://url")!,
                                                        accepts: "application/json",
                                                        form: [
                                                            IDXClient.Remediation.FormValue(name: "foo",
                                                                                            visible: false,
                                                                                            mutable: true,
                                                                                            required: false,
                                                                                            secret: false)
                                                        ],
                                                        relatesTo: nil,
                                                        refresh: nil)
        token = IDXClient.Token(accessToken: "access",
                                refreshToken: "refresh",
                                expiresIn: 10,
                                idToken: "id",
                                scope: "scope",
                                tokenType: "type")
        response = IDXClient.Response(api: api,
                                      stateHandle: "handle",
                                      version: "1",
                                      expiresAt: Date(),
                                      intent: "Login",
                                      authenticators: nil,
                                      authenticatorEnrollments: nil,
                                      currentAuthenticatorEnrollment: nil,
                                      remediation: nil,
                                      cancel: remediationOption,
                                      success: remediationOption,
                                      messages: nil,
                                      app: nil,
                                      user: nil)
    }

    override func tearDown() {
        delegate.reset()
        api.reset()
    }

    func testInteractError() {
        // interact
        api.expect(function: "interact(completion:)", arguments: ["error": error])
        waitFor { expectation in
            self.client.interact { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .error)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testIntrospectError() {
        api.expect(function: "introspect(_:completion:)", arguments: ["error": error])
        waitFor { expectation in
            self.client.introspect("foo") { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .error)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testCancelError() {
        api.expect(function: "cancel(completion:)", arguments: ["error": error])
        waitFor { expectation in
            self.client.cancel { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .error)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testProceedError() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["error": error])
        waitFor { expectation in
            self.client.proceed(remediation: self.remediationOption, data: [:]) { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .error)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testExchangeCodeError() {
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["error": error])
        waitFor { expectation in
            self.client.exchangeCode(using: self.response) { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .error)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }

    func testToken() {
        // exchangeCode()
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["token": token as Any])
        waitFor { expectation in
            self.client.exchangeCode(using: self.response) { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .token)
        XCTAssertEqual(delegate.calls.first?.token, token)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }

    func testExchangeCodeFromClient() {
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["token": token as Any])
        waitFor { expectation in
            self.client.exchangeCode(using: self.response) { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .token)
        XCTAssertEqual(delegate.calls.first?.token, token)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }

    func testExchangeCodeFromResponse() {
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["token": token as Any])
        waitFor { expectation in
            self.response.exchangeCode { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .token)
        XCTAssertEqual(delegate.calls.first?.token, token)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    

    func testIntrospect() {
        // introspect()
        api.expect(function: "introspect(_:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.client.introspect("foo") { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testCancelFromClient() {
        api.expect(function: "cancel(completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.client.cancel { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testCancelFromResponse() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.response.cancel { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testProceedFromClient() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.client.proceed(remediation: self.remediationOption, data: [:]) { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }

    func testProceedFromOption() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.remediationOption.proceed(with: [:]) { (_, _) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testTokenWithoutCompletionBlock() {
        // exchangeCode()
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["token": token as Any])
        waitFor { expectation in
            self.client.exchangeCode(using: self.response, completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .token)
        XCTAssertEqual(delegate.calls.first?.token, token)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testExchangeCodeFromClientWithoutCompletionBlock() {
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["token": token as Any])
        waitFor { expectation in
            self.client.exchangeCode(using: self.response, completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .token)
        XCTAssertEqual(delegate.calls.first?.token, token)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testExchangeCodeFromResponseWithoutCompletionBlock() {
        api.expect(function: "exchangeCode(using:completion:)", arguments: ["token": token as Any])
        waitFor { expectation in
            self.response.exchangeCode(completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .token)
        XCTAssertEqual(delegate.calls.first?.token, token)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    
    func testIntrospectWithoutCompletionBlock() {
        // introspect()
        api.expect(function: "introspect(_:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.client.introspect("foo", completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testCancelFromClientWithoutCompletionBlock() {
        api.expect(function: "cancel(completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.client.cancel(completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testCancelFromResponseWithoutCompletionBlock() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.response.cancel(completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testProceedFromClientWithoutCompletionBlock() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.client.proceed(remediation: self.remediationOption, data: [:], completion: nil)
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
    
    func testProceedFromOptionWithoutCompletionBlock() {
        api.expect(function: "proceed(remediation:data:completion:)", arguments: ["response": response as Any])
        waitFor { expectation in
            self.remediationOption.proceed(with: [:])
            self.client.queue.async {
                expectation.fulfill()
            }
        }
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.type, .response)
        XCTAssertEqual(delegate.calls.first?.response, response)
        XCTAssertEqual(delegate.calls.first?.isMainThread, true)
    }
}
