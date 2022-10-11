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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
protocol ComponentView {
    func body(in form: InputForm, section: some NativeAuthentication.Section) -> AnyView
    func shouldDisplay(in form: InputForm, section: some NativeAuthentication.Section) -> Bool
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ComponentView {
    func shouldDisplay(in form: InputForm, section: some NativeAuthentication.Section) -> Bool {
        true
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
protocol SectionView {
    associatedtype Body: View
    
    func body(in form: InputForm) -> Body
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FormLabel: ComponentView {
    public func body(in form: InputForm, section: some NativeAuthentication.Section) -> AnyView  {
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
extension Loading: ComponentView {
    public func body(in form: InputForm, section: some NativeAuthentication.Section) -> AnyView  {
        let result: any View
        if #available(iOS 14.0, *) {
            if let text = text {
                result = ProgressView {
                    Text(text)
                }
            } else {
                result = ProgressView()
            }
        } else {
            result = EmptyView()
        }
        
        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension StringInputField: ComponentView {
    func body(in form: InputForm, section: some NativeAuthentication.Section) -> AnyView {
        let result: any View
        result = VStack(spacing: 12.0) {
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
                
                if isSecure,
                   let inputSection = section as? InputSection,
                   let recoverAction = inputSection.components.first(type: RecoverAction.self)
                {
                    recoverAction.body(in: form, section: inputSection)
                }
            }
            Divider()
        }

        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ContinueAction: ComponentView {
    func body(in form: NativeAuthentication.InputForm, section: some NativeAuthentication.Section) -> AnyView {
        let result: any View
        switch intent {
        case .signIn:
            if #available(iOS 15.0, *) {
                result = Button {
                    self.action()
                } label: {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                result = Button {
                    self.action()
                } label: {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }
            
        case .signUp:
            result = HStack {
                Text("New to Example?")
                Button {
                    self.action()
                } label: {
                    Text("Sign up")
                        .bold()
                }
            }.padding()

        case .restart:
            if #available(iOS 15.0, *) {
                result = Button {
                    self.action()
                } label: {
                    Text("Restart")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                result = Button {
                    self.action()
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
extension SocialLoginAction: ComponentView {
    func body(in form: NativeAuthentication.InputForm, section: some NativeAuthentication.Section) -> AnyView {
        let result: any View
        switch provider {
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
        
        return AnyView(result)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension RecoverAction: ComponentView {
    func body(in form: NativeAuthentication.InputForm, section: some NativeAuthentication.Section) -> AnyView {
        AnyView(Button {
            self.action()
        } label: {
            Text("Forgot?")
                .font(.footnote)
                .bold()
        })
    }
    
    func shouldDisplay(in form: InputForm, section: some NativeAuthentication.Section) -> Bool {
        guard let inputSection = section as? InputSection else {
            return true
        }
        
        return inputSection.components
            .compactMap({ $0 as? StringInputField })
            .filter({ $0.isSecure })
            .isEmpty
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AnyComponent: Identifiable {
    public var id: String { component.id }
    public let component: any Component

    public init(_ component: any Component) {
        self.component = component
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AnySection: Identifiable {
    public let id: String
    public let section: any NativeAuthentication.Section

    public init(_ section: any NativeAuthentication.Section) {
        self.section = section
        self.id = section.id
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol InputFormTransformerDataSource {
    func view(for form: InputForm,
              @ViewBuilder content: () -> some View) -> any View
    func view(for form: InputForm,
              section: any NativeAuthentication.Section,
              @ViewBuilder content: () -> some View) -> any View
    func view(in form: InputForm,
              section: any NativeAuthentication.Section,
              component: any Component) -> any View
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct DefaultInputTransformerDataSource: InputFormTransformerDataSource {
    public init() {}
    
    public func view(for form: NativeAuthentication.InputForm,
                     content: () -> some View) -> any View
    {
        VStack(content: content)
            .padding(.horizontal, 32.0)
            .frame(maxWidth: .infinity)
    }

    public func view(for form: NativeAuthentication.InputForm,
                     section: any NativeAuthentication.Section,
                     content: () -> some View) -> any View
    {
        if let section = section as? any View {
            return section
        }
        
        else if section is HeaderSection {
            return VStack(content: content)
                .padding(.bottom, 12.0)
        }
        
        else if let section = section as? InputSection {
            return VStack(spacing: 12.0) {
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
                    }.padding(.bottom, 12.0)
                }

                content()
            }.padding(.bottom, 12.0)
        } else {
            return EmptyView()
        }
    }
    
    public func view(in form: NativeAuthentication.InputForm,
                     section: any NativeAuthentication.Section,
                     component: any NativeAuthentication.Component) -> any View
    {
        if let component = component as? any View {
            return component
        }
        
        else if let component = component as? ComponentView,
                  component.shouldDisplay(in: form, section: section)
        {
            return component.body(in: form, section: section)
        }
        
        else {
            return EmptyView()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InputFormRenderer: View {
    public var form: InputForm
    private let dataSource: any InputFormTransformerDataSource

    public init(form: InputForm, dataSource: any InputFormTransformerDataSource = DefaultInputTransformerDataSource()) {
        self.form = form
        self.dataSource = dataSource
    }
    
    public var body: some View {
        AnyView(dataSource.view(for: form) {
            ForEach(self.form.sections.map({ AnySection($0) })) { section in
                AnyView(self.dataSource.view(for: self.form,
                                             section: section.section,
                                             content: {
                    ForEach(section.section.components.map({ AnyComponent($0) })) { component in
                        AnyView(self.dataSource.view(in: self.form,
                                                     section: section.section,
                                                     component: component.component))
                    }
                }))
            }
        })
    }
}
