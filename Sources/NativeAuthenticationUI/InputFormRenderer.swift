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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InputFormRenderer: View {
    @ObservedObject var auth: NativeAuthentication
    
    private let dataSource: any InputFormTransformerDataSource

    public init(auth: NativeAuthentication, dataSource: any InputFormTransformerDataSource = DefaultInputTransformerDataSource()) {
        self.auth = auth
        self.dataSource = dataSource
    }
    
    public var body: some View {
        AnyView(dataSource.view(for: auth.form) {
            ForEach(self.auth.form.sections.map({ AnySection($0) })) { section in
                AnyView(self.dataSource.view(for: self.auth.form,
                                             section: section.section,
                                             content: {
                    ForEach(section.section.components.map({ AnyComponent($0) })) { component in
                        AnyView(self.dataSource.view(in: self.auth.form,
                                                     section: section.section,
                                                     component: component.component))
                    }
                }))
            }
        })
        .onAppear {
            Task {
                await auth.client.signIn()
            }
        }
        .animation(Animation.default.speed(1))
    }
}
