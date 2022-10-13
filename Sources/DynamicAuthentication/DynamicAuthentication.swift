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
    public let delegateCollection = DelegateCollection<AuthenticationProviderDelegate>()
    
    public let flow: InteractionCodeFlow
    public let responseTransformer: any ResponseTransformer
    
    public init(flow: InteractionCodeFlow,
                responseTransformer: any ResponseTransformer = DefaultResponseTransformer())
    {
        self.flow = flow
        self.responseTransformer = responseTransformer

        flow.add(delegate: self)
    }
    
    public convenience init(responseTransformer: any ResponseTransformer = DefaultResponseTransformer()) throws
    {
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
    
    public func start() async {
        do {
            try await flow.start()
        } catch {
            send(error)
        }
    }
    
    func send(_ form: SignInForm) {
        delegateCollection.invoke({ $0.authentication(provider: self, updated: form) })
    }

    func send(_ response: Response) {
        send(responseTransformer.signInForm(for: response))
    }

    func send(_ error: Error) {
        send(responseTransformer.signInForm(for: error))
    }
}

extension DynamicAuthenticationProvider: InteractionCodeFlowDelegate {
    public func authenticationStarted<Flow>(flow: Flow) {
        send(SignInForm.loading)
    }
    
    public func authenticationFinished<Flow>(flow: Flow) {
    }
    
    public func authentication<Flow>(flow: Flow, received token: Token) {
    }
    
    public func authenticationStarted<Flow>(flow: Flow) where Flow : InteractionCodeFlow {
        send(SignInForm.loading)
    }
    
    public func authenticationFinished<Flow>(flow: Flow) where Flow : InteractionCodeFlow {
    }
    
    public func authentication<Flow>(flow: Flow, received error: InteractionCodeFlowError) where Flow : InteractionCodeFlow {
        send(error)
    }
    
    public func authentication<Flow>(flow: Flow, received response: Response) where Flow : InteractionCodeFlow {
        send(response)
    }
    
    public func authentication<Flow>(flow: Flow, received token: Token) where Flow : InteractionCodeFlow {
    }
    
    public func authentication<Flow>(flow: Flow, received error: OAuth2Error) {
        send(error)
    }
}
