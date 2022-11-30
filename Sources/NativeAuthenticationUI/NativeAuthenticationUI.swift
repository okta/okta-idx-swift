import SwiftUI
import AuthenticationServices
@_exported import NativeAuthentication

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class NativeAuthentication: ObservableObject {
    @Published public private(set) var form: SignInForm
    @Published public private(set) var token: Token?
    
    public let client: AuthenticationClient
    public weak var presentationContextProvider: (any ASWebAuthenticationPresentationContextProviding)?

    private let initialForm: SignInForm
    private var webAuthSession: ASWebAuthenticationSession?

    public init(client: AuthenticationClient, initialForm: SignInForm = .empty) {
        self.initialForm = initialForm
        self.form = initialForm
        self.client = client
        client.add(delegate: self)
    }

    convenience public init(provider: any AuthenticationProvider, initialForm: SignInForm = .empty) {
        self.init(client: AuthenticationClient(provider: provider), initialForm: initialForm)
    }
    
    public func rendererView(dataSource: any InputFormTransformerDataSource = DefaultInputTransformerDataSource()) -> InputFormRenderer {
        .init(auth: self, dataSource: dataSource)
    }
    
    public func reset() {
        let storage = HTTPCookieStorage.shared
        if let cookie = storage.cookies?.filter({ $0.name == "idx"}).first {
            storage.deleteCookie(cookie)
        }

        form = initialForm
        token = nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NativeAuthentication: AuthenticationClientDelegate {
    public func authentication(client: AuthenticationClient, finished token: Token) {
        Task { @MainActor in
            self.token = token
        }
    }
    
    public func authentication(client: AuthenticationClient, updated form: SignInForm) {
        Task { @MainActor in
            print(form)
            self.form = form
        }
    }
    
    public func authentication(client: AuthenticationClient, idp provider: RedirectIDP.Provider, redirectTo url: URL, callback scheme: String) {
        Task { @MainActor in
            let session = ASWebAuthenticationSession(url: url,
                                                     callbackURLScheme: scheme)
            { [weak self] (callbackURL, error) in
                guard let self = self else { return }
                
                if let error = error {
                    client.idp(provider, error: error)
                } else if let callbackURL = callbackURL {
                    client.idp(provider, finished: callbackURL)
                } else {
                    client.idp(provider, error: AuthenticationClientError.idpRedirect)
                }
                
                self.webAuthSession = nil
            }
            
            session.presentationContextProvider = presentationContextProvider
            session.start()
            
            self.webAuthSession = session
        }
    }
}
