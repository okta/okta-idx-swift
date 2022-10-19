import Foundation

@_exported import AuthFoundation

public protocol AuthenticationProviderDelegate {
    func authentication(provider: any AuthenticationProvider, updated form: SignInForm)
    func authentication(provider: any AuthenticationProvider, finished token: Token)
}

public protocol AuthenticationProvider: UsesDelegateCollection where Delegate == AuthenticationProviderDelegate {
    func signIn(_ completion: @escaping (_ token: Token) -> Void) async
}

public protocol AuthenticationClientDelegate {
    func authentication(client: AuthenticationClient, updated form: SignInForm)
    func authentication(client: AuthenticationClient, finished token: Token)
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
    public func signIn(_  completion: @escaping (_ token: Token) -> Void) async {
        await provider.signIn(completion)
    }
    
    func send(_ form: SignInForm) {
        delegateCollection.invoke({ $0.authentication(client: self, updated: form) })
    }

    func send(_ token: Token) {
        delegateCollection.invoke({ $0.authentication(client: self, finished: token) })
    }
}

extension AuthenticationClient: AuthenticationProviderDelegate {
    public func authentication(provider: any AuthenticationProvider, finished token: Token) {
        send(token)
    }
    
    public func authentication(provider: any AuthenticationProvider, updated form: SignInForm) {
        send(form)
    }
}
