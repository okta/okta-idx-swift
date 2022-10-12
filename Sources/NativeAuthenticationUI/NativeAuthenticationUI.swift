import SwiftUI
@_exported import NativeAuthentication

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class NativeAuthentication: ObservableObject {
    @Published public private(set) var form: SignInForm
    public let client: AuthenticationClient
    
    public init(client: AuthenticationClient, initialForm: SignInForm = .empty) {
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
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NativeAuthentication: AuthenticationClientDelegate {
    public func authentication(client: AuthenticationClient, updated form: SignInForm) {
        Task { @MainActor in
            self.form = form
        }
    }
}
