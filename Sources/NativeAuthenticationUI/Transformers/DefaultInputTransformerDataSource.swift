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
                     content: ([any SignInSection]) -> some View) -> any View
    {
        ScrollView(.vertical) {
            VStack {
                content(form.sections)
            }
            .padding(.horizontal, 32.0)
            .frame(maxWidth: .infinity)
        }.compatibility.scrollDismissesKeyboard(.interactively)
    }

    public func view(for form: SignInForm,
                     section: any SignInSection,
                     content: ([any SignInComponent]) -> some View) -> any View
    {
        if let section = section as? any View {
            return section
        }
        
        else if let section = section as? HeaderSection {
            return HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    content(section.leftComponents)
                }.frame(alignment: .leading)
                
                VStack(alignment: .center, spacing: 8) {
                    content(section.components)
                }.frame(maxWidth: .infinity, alignment: .center)
                
                HStack(alignment: .center, spacing: 8) {
                    content(section.rightComponents)
                }.frame(alignment: .trailing)
            }
            .padding(12.0)
            .frame(maxWidth: .infinity)
        }
        
        else if section is RedirectIDP {
            return VStack(spacing: 12.0) {
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
                
                content(section.components)
            }.padding(.bottom, 12.0)
        }
        
        else {
            return VStack(spacing: 12.0) {
                content(section.components)
            }.padding(.bottom, 12.0)
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
