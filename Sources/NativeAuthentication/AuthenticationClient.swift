import Foundation

public protocol AuthenticationClientDelegate {
    func authentication(client: AuthenticationClient, updated form: SignInForm)
    func authentication(client: AuthenticationClient, finished token: Token)
    func authentication(client: AuthenticationClient, idp provider: RedirectIDP.Provider, redirectTo url: URL, callback scheme: String)
}

public enum AuthenticationClientError: Error {
    case idpRedirect
}

public class AuthenticationClient: UsesDelegateCollection, ObservableObject {
    public typealias Delegate = AuthenticationClientDelegate

    let provider: any AuthenticationProvider
    public private(set) var form: SignInForm {
        didSet {
            self.delegateCollection.invoke({ $0.authentication(client: self, updated: form) })
        }
    }

    public let delegateCollection = DelegateCollection<AuthenticationClientDelegate>()

    public init(provider: any AuthenticationProvider) {
        self.form = .empty
        self.provider = provider
        self.provider.add(delegate: self)
    }
    
    @MainActor
    public func signIn() async {
        await provider.signIn()
    }
    
    public func idp(_ idp: RedirectIDP.Provider, finished callbackURL: URL) {
        
    }

    public func idp(_ idp: RedirectIDP.Provider, error: Error) {
        
    }
}

extension AuthenticationClient: AuthenticationProviderDelegate {
    public func authentication(provider: any AuthenticationProvider, finished token: Token) {
        delegateCollection.invoke { $0.authentication(client: self, finished: token) }
    }
    
    public func authentication(provider: any AuthenticationProvider, updated form: SignInForm) {
        delegateCollection.invoke { $0.authentication(client: self, updated: form) }
    }
    
    public func authentication(provider: any AuthenticationProvider, idp: RedirectIDP.Provider, redirectTo url: URL, callback scheme: String) {
        delegateCollection.invoke { $0.authentication(client: self, idp: idp, redirectTo: url, callback: scheme) }
    }
}
