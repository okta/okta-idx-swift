import OktaIdx

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol Section: Identifiable {
    static var type: SectionType { get }

    var id: String { get }
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
    public let actions: [any Action]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AnySection: Identifiable {
    public let id: String
    public let section: any Section

    public init(_ section: any Section) {
        self.section = section
        self.id = section.id
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Collection where Element == any Action {
    public func with<T: Action>(type: T.Type) -> [T] {
        compactMap({ $0 as? T })
    }

    public func first<T: Action>(type: T.Type) -> T? {
        first(where: { $0 is T }) as? T
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InputForm {
    public enum Intent {
        case signIn, empty
    }
    
    public let intent: Intent
    public let sections: [any Section]

    public static let empty = InputForm(intent: .empty, sections: [])
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
                        StringInputField(id: "credential.passcode", label: "Password", isSecure: true, value: "")
                    ], actions: [
                        ContinueAction(id: "identifier", intent: .signIn, label: "Sign in"),
                        RecoverAction(id: "recover")
                    ]),

                InputSection(
                    id: "idp",
                    components: [],
                    actions: [
                        SocialLoginAction(id: "idp", provider: .apple)
                    ]),

                InputSection(
                    id: "ssr",
                    components: [],
                    actions: [
                        SignUpAction(id: "ssr")
                    ])
            ])
    }()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol InputComponent: Identifiable {
    
}

