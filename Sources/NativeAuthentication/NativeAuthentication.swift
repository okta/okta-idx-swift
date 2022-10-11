import OktaIdx

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol Section: Identifiable {
    static var type: SectionType { get }

    var id: String { get }
    var components: [any Component] { get }
}

public enum SectionType {
    case header, body, footer
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct HeaderSection: Section, Identifiable {
    public static let type = SectionType.header
    
    public let id: String
    public let components: [any Component]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InputSection: Section, Identifiable {
    public static let type = SectionType.body
    
    public let id: String
    public let components: [any Component]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Collection where Element == any Component {
    public func with<T: Component>(type: T.Type) -> [T] {
        compactMap({ $0 as? T })
    }

    public func first<T: Component>(type: T.Type) -> T? {
        first(where: { $0 is T }) as? T
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InputForm {
    public enum Intent {
        case signIn, empty, loading
    }
    
    public let intent: Intent
    public let sections: [any Section]

    public static let empty = InputForm(intent: .empty, sections: [])
    public static let loading = InputForm(intent: .loading, sections: [
        HeaderSection(id: "loading", components: [
            Loading(id: "loadingIndicator")
        ])
    ])
    
    public static let `default`: InputForm = {
        InputForm(
            intent: .signIn,
            sections: [
                HeaderSection(id: "header", components: [
                    FormLabel(id: "Foo", text: "Sign In", style: .heading)
                ]),
                
                InputSection(
                    id: "identify",
                    components: [
                        StringInputField(id: "identifier", label: "Username", isSecure: false, value: ""),
                        StringInputField(id: "credential.passcode", label: "Password", isSecure: true, value: ""),
                        ContinueAction(id: "identifier.action", intent: .signIn, label: "Sign in") {
                            print("Continue")
                        },
                        RecoverAction(id: "recover") {
                            print("Recover")
                        }
                    ]),

                InputSection(
                    id: "idp",
                    components: [
                        SocialLoginAction(id: "idp", provider: .apple) {
                            print("IDP")
                        }
                    ]),

                InputSection(
                    id: "ssr",
                    components: [
                        ContinueAction(id: "ssr", intent: .signUp, label: "Sign up") {
                            print("Sign up")
                        }
                    ])
            ])
    }()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol InputComponent: Identifiable {
    
}

