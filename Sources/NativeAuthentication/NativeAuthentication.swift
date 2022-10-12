import Foundation

@_exported import AuthFoundation

public protocol AuthenticationProvider {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol AuthenticationClientDelegate {
    func authentication(client: AuthenticationClient, updated form: InputForm)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class AuthenticationClient: UsesDelegateCollection {
    let provider: any AuthenticationProvider

    public let delegateCollection = DelegateCollection<AuthenticationClientDelegate>()

    public init(provider: any AuthenticationProvider) {
        self.provider = provider
    }
    
    public func start() async throws {
        let form = InputForm.default
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.delegateCollection.call { delegate in
                delegate.authentication(client: self, updated: form)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AuthenticationClient: UsesDelegateCollection {
    public typealias Delegate = AuthenticationClientDelegate
}
