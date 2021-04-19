/*
 * Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import UIKit
import OktaIdx

class TokenResultViewController: UIViewController {
    var client: IDXClient?
    var token: IDXClient.Token?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let token = token else {
            textView.text = "No token was found"
            return
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byCharWrapping
        paragraph.paragraphSpacing = 15
        
        let bold = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        let normal = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                      NSAttributedString.Key.paragraphStyle: paragraph]
        
        func addString(to string: NSMutableAttributedString, title: String, value: String) {
            string.append(NSAttributedString(string: "\(title):\n", attributes: bold))
            string.append(NSAttributedString(string: "\(value)\n", attributes: normal))
        }
        
        let string = NSMutableAttributedString()
        addString(to: string, title: "Access token", value: token.accessToken)
        
        if let refreshToken = token.refreshToken {
            addString(to: string, title: "Refresh token", value: refreshToken)
        }
        
        addString(to: string, title: "Expires in", value: "\(token.expiresIn) seconds")
        addString(to: string, title: "Scope", value: token.scope)
        addString(to: string, title: "Token type", value: token.tokenType)
        
        if let idToken = token.idToken {
            addString(to: string, title: "ID token", value: idToken)
        }
        
        textView.attributedText = string
    }
    
    @IBAction func revokeAction(_ sender: Any) {
        guard let client = self.client,
              let token = self.token
        else { return }
        let prompt = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        prompt.addAction(.init(title: "All Tokens", style: .default) { (alert) in
            client.revoke(token: token, type: .accessAndRefreshToken) { (response, error) in
                self.tokenRevoked(response, error: error)
            }
        })
        prompt.addAction(.init(title: "Refresh Token", style: .default) { (alert) in
            client.revoke(token: token, type: .refreshToken) { (response, error) in
                self.tokenRevoked(response, error: error)
            }
        })
        prompt.addAction(.init(title: "Cancel", style: .cancel))
        present(prompt, animated: true)
    }
    
    func tokenRevoked(_ success: Bool, error: Error?) {
        let alert: UIAlertController
        if success {
            alert = .init(title: "Token revoked",
                          message: "Your token has been revoked successfully",
                          preferredStyle: .alert)
        } else {
            alert = .init(title: "Revoke failed",
                          message: error?.localizedDescription ?? "Could not revoke your token",
                          preferredStyle: .alert)
        }
        
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
