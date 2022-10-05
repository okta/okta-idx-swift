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

import SwiftUI
import NativeAuthentication
import AuthFoundation
import OktaIdx

#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol ComponentViewTransformer {
    associatedtype ComponentView: View
    
    func view(for component: some Component) -> ComponentView
}

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct DefaultComponentViewTransformer: ComponentViewTransformer {
//    func view(for component: some Component) -> some View {
//        if let component = component as? FormLabel {
//            switch component.style {
//            case .heading:
//                return Text(component.text)
//                    .font(.largeTitle)
//                    .fontWeight(.heavy)
//                    .padding(.bottom)
//            case .caption:
//                return Text(component.text)
//                    .font(.callout)
//            case .description:
//                return Text(component.text)
//                    .font(.body)
//            }
//        } else {
//            let label = "Unknown component \(component)"
//            return Text(label)
//        }
//    }
//
////    func view(for intent: InputForm.Intent, title: String?) -> AnyView {
////        guard let title = title else {
////            return AnyView(EmptyView())
////        }
////
////        return AnyView(Text(title)
////            .font(.largeTitle)
////            .fontWeight(.heavy)
////            .padding(.bottom))
////    }
//}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnyComponent: View {
    public var body: some View {
        if let component = component as? (any View) {
            return AnyView(component.body)
        } else {
            return AnyView(EmptyView())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnySection: View {
    public var body: some View {
        if let section = section as? HeaderSection {
            return AnyView(section.body)
        } else if let section = section as? InputSection {
            return AnyView(section.body)
        } else {
            return AnyView(EmptyView())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension InputForm: View {
    public var body: some View {
        VStack {
            ForEach(sections.map({ AnySection($0)})) { section in
                section.body
            }
        }.padding(.horizontal, 32.0)
            .frame(maxWidth: .infinity)
    }
    
//    public func body(using transformer: (any InputFormTransformerDataSource)?) -> some View {
//        var result = VStack {
//            ForEach(sections.map({ AnySection($0)})) { section in
//                Text("Section \(section.id)")
//                section.body
//            }
//        }.padding(.horizontal, 32.0)
//            .frame(maxWidth: .infinity)
//
//        if let transformer = transformer {
//            return AnyView(transformer.view(for: self, replacing: result))
//        } else {
//            return AnyView(result)
//        }
//    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FormLabel: View {
    public var body: some View {
        let result: any View
        switch style {
        case .heading:
            result = Text(text)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.bottom)
        case .caption:
            result = Text(text)
                .font(.callout)
        case .description:
            result = Text(text)
                .font(.body)
        }
        
        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension StringInputField: View {
    public var body: some View {
        let result: any View
        result = VStack(spacing: 6.0) {
            HStack {
                if isSecure {
                    Image(systemName: "lock")
                } else if id == "identifier" {
                    Image(systemName: "at")
                }
                TextField(label, text: Binding<String>(
                    get: { value },
                    set: { value = $0 }
                ))
                
                if id == "credentials.passcode" {
                    Button {
                        // DO nothing
                    } label: {
                        Text("Forgot?")
                            .font(.footnote)
                            .bold()
                    }
                }
            }
            Divider()
        }

        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ContinueAction: View {
    public var body: some View {
        let result: any View
        switch intent {
        case .signIn:
            if #available(iOS 15.0, *) {
                result = Button {
                    // Do nothing
                } label: {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                result = Button {
                    // Do nothing
                } label: {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }
            
        case .signUp:
            if #available(iOS 15.0, *) {
                result = Button {
                    // Do nothing
                } label: {
                    Text("Sign up a new user")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                result = Button {
                    // Do nothing
                } label: {
                    Text("Sign up a new user")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }

        case .restart:
            if #available(iOS 15.0, *) {
                result = Button {
                    // Do nothing
                } label: {
                    Text("Restart")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                result = Button {
                    // Do nothing
                } label: {
                    Text("Restart")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }
        }
        
        return AnyView(result)
    }
}


@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension HeaderSection: View {
    public var body: some View {
        let result: any View
        result = VStack {
            ForEach(components.map({ AnyComponent($0)})) { component in
                component.body
            }
        }
        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension InputSection: View {
    public var body: some View {
        let result: any View
        result = VStack {
            ForEach(components.map({ AnyComponent($0)})) { component in
                component.body
            }
        }
        return AnyView(result)
    }
    
    public func body(using transformer: InputFormTransformer) -> some View {
        let result: any View
        result = VStack {
            ForEach(components.map({ AnyComponent($0)})) { component in
                component.body
            }
        }
        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol InputFormTransformerDataSource: AnyObject {
    associatedtype Body: View
    
    func view(for section: AnySection,
              in form: InputForm,
              replacing view: some View) -> Body

    func view(for form: InputForm,
              replacing view: some View) -> Body
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class InputFormTransformer {
    public var form: InputForm
    public weak var dataSource: (any InputFormTransformerDataSource)?
    
    public init(form: InputForm) {
        self.form = form
    }
    
    public func body() -> some View {
//        form.body(using: dataSource)
        form.body
    }
}

/*
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class InputFormTransformer {
    public var form: InputForm
    @State var value: String = ""
    
    let dataSources: [Remediation.RemediationType: any ComponentViewTransformer]
//    let defaultDataSource = DefaultComponentViewTransformer()
    
    public init(form: InputForm) {
        self.form = form
        dataSources = [:]
    }
    
    public func body() -> some View {
        VStack {
            view(for: form.intent)
            ForEach(form.sections) { section in
                self.view(for: section as! InputSection)
            }
        }.padding(.horizontal, 32.0)
            .frame(maxWidth: .infinity)
    }
    
    func componentTransformer(for remediation: Remediation) -> any ComponentViewTransformer {
        dataSources[remediation.type] ?? defaultDataSource
    }
    
    func view(for section: InputSection) -> some View {
        VStack(spacing: 12.0) {
            if section.id == "idp" {
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("Or sign in with")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    VStack {
                        Divider()
                    }
                }.padding(.vertical)
            }
            
            ForEach(section.fields.map({ AnyInputField($0) })) { field in
                self.view(for: field.inputField, in: section)
            }
            
            ForEach(section.actions.map({ AnyAction($0) })) { action in
                self.view(for: action.action, in: section)
            }
        }
    }
    
    func view(for field: any InputField, in section: InputSection) -> some View {
        if let field = field as? StringInputField {
            return AnyView(
                VStack(spacing: 6.0) {
                    HStack {
                        if field.isSecure {
                            Image(systemName: "lock")
                        } else if field.id == "identifier" {
                            Image(systemName: "at")
                        }
                        TextField(field.label, text: Binding<String>(
                            get: { field.value },
                            set: { field.value = $0 }
                        ))
                        
                        if field.isSecure,
                           _ = section.actions.first(type: RecoverAction.self)
                        {
                            Button {
                                // DO nothing
                            } label: {
                                Text("Forgot?")
                                    .font(.footnote)
                                    .bold()
                            }
                        }
                    }
                    Divider()
                }.padding(.bottom)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    func view(for action: any Action, in section: InputSection) -> some View {
        var result: any View
        if let action = action as? ContinueAction {
            if #available(iOS 15.0, *) {
                result = Button {
                    // Do nothing
                } label: {
                    Text(action.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                result = Button {
                    // Do nothing
                } label: {
                    Text(action.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }
        } else if let action = action as? SocialLoginAction {
            switch action.provider {
            case .apple:
#if canImport(AuthenticationServices)
                if #available(iOS 14.0, *) {
                    result = SignInWithAppleButton { request in
                        // Do nothing
                    } onCompletion: { result in
                        // Do nothing
                    }.frame(maxHeight: 50)
                } else {
                    fallthrough
                }
#else
                fallthrough
#endif
            default:
                result = EmptyView()
            }
        } else if let action = action as? SignUpAction {
            result = HStack {
                Text("New to Example?")
                Button {
                    // DO nothing
                } label: {
                    Text("Sign up")
                        .bold()
                }
            }.padding()
        } else {
            result = EmptyView()
        }

        return AnyView(result)
    }
}
*/
