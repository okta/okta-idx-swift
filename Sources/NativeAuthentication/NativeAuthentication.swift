import Foundation

@_exported import AuthFoundation

public protocol AuthenticationProvider {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol AuthenticationClientDelegate {
    func authentication(client: AuthenticationClient, updated form: SignInForm)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class AuthenticationClient: UsesDelegateCollection {
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
    }
    
    @MainActor
    public func start() async throws {
        self.form = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.form = SignInForm.default
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AuthenticationClient: UsesDelegateCollection {
    public typealias Delegate = AuthenticationClientDelegate
}
