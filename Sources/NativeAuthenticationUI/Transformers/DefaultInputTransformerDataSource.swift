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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class DefaultInputTransformerDataSource: InputFormTransformerDataSource {
    public init() {}
    
    public func view(for form: SignInForm,
                     content: () -> some View) -> any View
    {
        ScrollView(.vertical) {
            VStack(content: content)
                .padding(.horizontal, 32.0)
                .frame(maxWidth: .infinity)
        }.compatibility.scrollDismissesKeyboard(.interactively)
    }

    public func view(for form: SignInForm,
                     section: any SignInSection,
                     content: () -> some View) -> any View
    {
        if let section = section as? any View {
            return section
        }
        
        else if section is HeaderSection {
            return VStack(content: content)
                .padding(.bottom, 12.0)
        }
        
        else if section is BodySection {
            return VStack(spacing: 12.0) {
                if section.id == "redirect-idp" {
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
    
    public func view(in form: SignInForm,
                     section: any SignInSection,
                     component: any SignInComponent) -> any View
    {
        if let component = component as? any View {
            return component
        }
        
        else if let component = component as? (any ComponentView),
                  component.shouldDisplay(in: form, section: section)
        {
            return component.body(in: form, section: section)
        }
        
        else {
            return EmptyView()
        }
    }
}
