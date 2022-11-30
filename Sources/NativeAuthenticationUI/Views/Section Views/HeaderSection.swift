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
extension HeaderSection: SectionView {
    @ViewBuilder
    func body(in form: SignInForm, @ViewBuilder renderer: ([any SignInComponent]) -> some View) -> any View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 8) {
                renderer(leftComponents)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .center, spacing: 8) {
                renderer(components)
            }.frame(maxWidth: .infinity, alignment: .center)
            
            HStack(alignment: .center, spacing: 8) {
                renderer(rightComponents)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 12.0)
        .frame(maxWidth: .infinity)
    }
}
