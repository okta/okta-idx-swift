//
// Copyright (c) 2022-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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
import AuthFoundation
import OktaIdx

@_exported import NativeAuthentication

public final class DynamicAuthenticationProvider: AuthenticationProvider {
    struct State {
        let form: SignInForm
        let response: Response?
        let error: Error?
        
        init(form: SignInForm, response: Response? = nil, error: Error? = nil) {
            self.form = form
            self.response = response
            self.error = error
        }
    }
    
    public let delegateCollection = DelegateCollection<AuthenticationProviderDelegate>()
    
    private(set) var state: State {
        didSet {
            delegateCollection.invoke({ $0.authentication(provider: self, updated: state.form) })
        }
    }
    
    public let flow: InteractionCodeFlow
    public let responseTransformer: any ResponseTransformer
    internal private(set) var expirationTimer: DispatchSourceTimer?
    internal private(set) var restartCause: Error?
    
    public init(flow: InteractionCodeFlow,
                responseTransformer: any ResponseTransformer = DefaultResponseTransformer())
    {
        self.flow = flow
        self.responseTransformer = responseTransformer
        self.state = .init(form: .empty)

        flow.add(delegate: self)
    }
    
    public convenience init(responseTransformer: any ResponseTransformer = DefaultResponseTransformer()) throws {
        self.init(flow: try InteractionCodeFlow(), responseTransformer: responseTransformer)
    }
    
    public convenience init(plist fileURL: URL,
                            responseTransformer: any ResponseTransformer = DefaultResponseTransformer()) throws
    {
        try self.init(flow: .init(plist: fileURL),
                      responseTransformer: responseTransformer)
    }
    
    public convenience init(issuer: URL,
                            clientId: String,
                            scopes: String,
                            redirectUri: URL,
                            additionalParameters: [String: String]? = nil,
                            responseTransformer: any ResponseTransformer = DefaultResponseTransformer())
    {
        self.init(flow: .init(issuer: issuer,
                              clientId: clientId,
                              scopes: scopes,
                              redirectUri: redirectUri,
                             additionalParameters: additionalParameters),
                  responseTransformer: responseTransformer)
    }
    
    public func signIn() async {
        do {
            if flow.isAuthenticating {
                _ = try await flow.resume()
            } else {
                _ = try await flow.start()
            }
        } catch {
            send(error)
        }
    }
    
    func resetExpiration(date: Date) {
        expirationTimer?.cancel()

        let interval = max(0.0, date.coordinated.timeIntervalSinceNow)
        let timerSource = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timerSource.schedule(deadline: .now() + interval,
                             repeating: .never)
        timerSource.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.restart()
        }
        timerSource.resume()

        expirationTimer = timerSource
    }
    
    func restart(with error: Error? = nil) {
        expirationTimer?.cancel()
        expirationTimer = nil
        flow.cancel()
        restartCause = error
        
        Task {
            try await flow.start()
        }
    }
    
    func send(_ token: Token) {
        delegateCollection.invoke({ $0.authentication(provider: self, finished: token) })
    }

    func send(_ response: Response) {
        // Stop polling the previous response
        state.response?.stopPolling()
        
        let form = responseTransformer.form(for: response, in: self)
        state = .init(form: form, response: response)
        
        // Start polling the new response
        state.response?.startPolling()
        
        if let error = restartCause {
            send(error)
            restartCause = nil
        }
    }

    func send(_ error: Error) {
        let form = responseTransformer.form(for: error, in: self)
        state = .init(form: form, response: state.response, error: error)
    }
}

extension DynamicAuthenticationProvider: InteractionCodeFlowDelegate {
    public func authenticationStarted<Flow>(flow: Flow) {
        state = .init(form: responseTransformer.loading)
        
        let storage = HTTPCookieStorage.shared
        print(storage)
    }
    
    public func authenticationFinished<Flow>(flow: Flow) {
    }
    
    public func authentication<Flow>(flow: Flow, received token: Token) {
    }
    
    public func authenticationStarted<Flow>(flow: Flow) where Flow : InteractionCodeFlow {
        state = .init(form: SignInForm.loading)
    }
    
    public func authenticationFinished<Flow>(flow: Flow) where Flow : InteractionCodeFlow {
    }
    
    public func authentication<Flow>(flow: Flow, received error: InteractionCodeFlowError) where Flow : InteractionCodeFlow {
        send(error)
    }
    
    public func authentication<Flow>(flow: Flow, received response: Response) where Flow : InteractionCodeFlow {
        if response.isLoginSuccessful {
            state = .init(form: responseTransformer.success)
            response.exchangeCode()
        } else {
            if let expirationDate = response.expiresAt {
                resetExpiration(date: expirationDate)
            }
            
            send(response)
        }
    }
    
    public func authentication<Flow>(flow: Flow, received token: Token) where Flow : InteractionCodeFlow {
        send(token)
    }
    
    public func authentication<Flow>(flow: Flow, received error: OAuth2Error) {
        send(error)
    }
}

extension Remediation.Form.Field: SignInValueBacking {
    public var backingValue: Any {
        get { value ?? "" }
        set {
            guard let newValue = newValue as? APIRequestArgument else { return }
            value = newValue
        }
    }
}

extension Response {
    var allPollable: [Capability.Pollable] {
        authenticators.compactMap { authenticator in
            authenticator.capability(Capability.Pollable.self)
        }
    }

    func startPolling() {
        allPollable.forEach { pollable in
            pollable.startPolling()
        }
    }
    
    func stopPolling() {
        allPollable.forEach { pollable in
            pollable.stopPolling()
        }
    }
}
