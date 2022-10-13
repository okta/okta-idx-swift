import Foundation

@_exported import AuthFoundation

public protocol AuthenticationProviderDelegate {
    func authentication(provider: any AuthenticationProvider, updated form: SignInForm)
}

public protocol AuthenticationProvider: UsesDelegateCollection where Delegate == AuthenticationProviderDelegate {
    func start() async
}

public protocol AuthenticationClientDelegate {
    func authentication(client: AuthenticationClient, updated form: SignInForm)
}

public class AuthenticationClient: UsesDelegateCollection {
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
    public func start() async {
        await provider.start()
    }
    
    func send(form: SignInForm) {
        delegateCollection.invoke({ $0.authentication(client: self, updated: form) })
    }
}

extension AuthenticationClient: AuthenticationProviderDelegate {
    public func authentication(provider: any AuthenticationProvider, updated form: SignInForm) {
        send(form: form)
    }
}
