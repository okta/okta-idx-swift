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
extension ContinueAction: ComponentView {
    @ViewBuilder
    func body(in form: SignInForm, section: any SignInSection) -> some View {
        switch intent {
        case .signIn, .continue:
            if #available(iOS 15.0, *) {
                Button {
                    self.action()
                } label: {
                    Text(label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    self.action()
                } label: {
                    Text(label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }
            
        case .signUp:
            HStack {
                Text("New to Example?")
                Button {
                    self.action()
                } label: {
                    Text(label)
                        .bold()
                }
            }.padding()

        case .back:
            Button {
                self.action()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title)
            }

        case .restart:
            if #available(iOS 15.0, *) {
                Button(role: .cancel) {
                    self.action()
                } label: {
                    Text(label)
                }
            } else {
                Button {
                    self.action()
                } label: {
                    Text(label)
                }
            }
        }
    }
    
    func shouldDisplay(in form: SignInForm, section: any SignInSection) -> Bool {
        if intent == .restart,
           section is HeaderSection,
           form.sections.contains(where: { $0 is IdentifyUser })
        {
            return false
        }
        
        return true
    }
}

#if DEBUG
struct ContinueAction_Previews: PreviewProvider {
    static var previews: some View {
        let section = GenericSection {[]}
        let form = SignInForm(intent: .custom) {
            section
        }
        
        VStack(spacing: 20) {
            ContinueAction(id: "continue", intent: .continue, label: "Continue", action: {})
                .body(in: form, section: section)
            ContinueAction(id: "signIn", intent: .signIn, label: "Sign in", action: {})
                .body(in: form, section: section)
            ContinueAction(id: "signUp", intent: .signUp, label: "Register", action: {})
                .body(in: form, section: section)
            ContinueAction(id: "restart", intent: .restart, label: "Restart", action: {})
                .body(in: form, section: section)
            ContinueAction(id: "back", intent: .back, label: "Go back", action: {})
                .body(in: form, section: section)
        }
        .padding(20)
    }
}
#endif
