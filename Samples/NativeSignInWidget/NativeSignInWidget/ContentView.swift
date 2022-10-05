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
import AuthenticationServices
import NativeAuthenticationUI

struct ContentView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var rememberMe: Bool = false
    
    var body: some View {
        HStack(spacing: 50.0) {
            InputForm.default
//            SignInView(transformer: InputFormTransformer(form: .default))
//                .frame(maxWidth: .infinity)
            
            VStack(spacing: 12.0) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                HStack {
                    Image(systemName: "at")
                    TextField("Username", text: $username)
                }
                Divider()
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                    Button {
                        // DO nothing
                    } label: {
                        Text("Forgot?")
                            .font(.footnote)
                            .bold()
                    }
                }
                Divider()
                
                Button {
                    // Do nothing
                } label: {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
                
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
                
                SignInWithAppleButton { request in
                    // Do nothing
                } onCompletion: { result in
                    // Do nothing
                }.frame(maxHeight: 50)
                
                HStack {
                    Text("New to Example?")
                    Button {
                        // DO nothing
                    } label: {
                        Text("Sign up")
                            .bold()
                    }
                }.padding()
            }
            .padding(.horizontal, 32.0)
            .frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity)
    }
}

//protocol InputField {
//}
//
//struct StringInputField: InputField {
//    let label: String
//    let name: String
//    let isSecure: Bool
//
//    @State var value: String = ""
//}

//protocol InputAction {
//}
//
//struct ContinueAction: InputAction {
//    enum Intent {
//        case signIn
//        case signUp
//        case restart
//    }
//
//    let intent: Intent
//}
//
//struct SocialLoginAction: InputAction {
//    enum Provider {
//        case apple
//    }
//
//    let provider: Provider
//}
//
//struct SignUpAction: InputAction {
//}

struct SignInView: View {
    let transformer: InputFormTransformer

    var body: some View {
        transformer.body()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .previewInterfaceOrientation(.landscapeRight)
    }
}
