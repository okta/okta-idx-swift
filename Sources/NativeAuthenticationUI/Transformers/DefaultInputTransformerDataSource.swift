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

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class DefaultInputTransformerDataSource: InputFormTransformerDataSource {
    public init() {}
    
    func separate(sections: [any SignInSection]) -> (HeaderSection?, [any SignInSection]) {
        let header = sections.compactMap({ $0 as? HeaderSection }).first
        let sections = sections.filter({ !($0 is HeaderSection) })
        return (header, sections)
    }
    
    public func view(for form: SignInForm,
                     renderer: ([any SignInSection]) -> some View) -> any View
    {
        let (header, sections) = separate(sections: form.sections)
        
        return VStack(spacing: 12.0) {
            if let header = header {
                renderer([header])
            }
            
            ScrollView(.vertical) {
                VStack {
                    if let logo = form.theme?.logoImage {
                        Image(uiImage: logo)
                        Divider().padding(.vertical, 16)
                    }
                    renderer(sections)
                }
                .padding(.horizontal, 32.0)
                .frame(maxWidth: .infinity)
            }.compatibility.scrollDismissesKeyboard(.interactively)
        }
    }

    public func view(for form: SignInForm,
                     section: any SignInSection,
                     renderer: ([any SignInComponent]) -> some View) -> any View
    {
        if let section = section as? any View {
            return section
        }
        
        else if let sectionView = section as? (any SectionView),
                sectionView.shouldDisplay(in: form)
        {
            return sectionView.body(in: form, renderer: renderer)
        }
        
        else {
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
