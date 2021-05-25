//
// Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
// The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and limitations under the License.
//

import UIKit
import OktaIdx

class LandingViewController: UIViewController {
    @IBOutlet weak private(set) var signInButtonStackView: UIStackView!
    @IBOutlet weak private(set) var signInButton: SigninButton!
    @IBOutlet weak private(set) var footerView: UIView!
    @IBOutlet weak var configurationInfoLabel: UILabel!
    private var signin: Signin?

    var isSignInAvailable: Bool = false {
        didSet {
            signInButton.isEnabled = isSignInAvailable
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationUpdated(UserManager.shared.configuration)
        NotificationCenter.default.addObserver(forName: .configurationChanged, object: nil, queue: .main) { (note) in
            self.configurationUpdated(note.object as? IDXClient.Configuration)
        }
        
        if !isSignInAvailable {
            performSegue(withIdentifier: "ConfigureSegue", sender: nil)
        }
    }
    
    func configurationUpdated(_ configuration: IDXClient.Configuration?) {
        isSignInAvailable = configuration != nil
        if let configuration = configuration {
            configurationInfoLabel.text = """
            Client ID: \(configuration.clientId)
            """
            signin = Signin(using: configuration)
        } else {
            configurationInfoLabel.text = "Please configure your client"
            signin = nil
        }
    }
    
    @IBAction func logIn(_ sender: Any) {
        guard let signin = signin else {
            return
        }
        
        signin.signin(from: self) { [weak self] (user, error) in
            if let error = error {
                print("Could not sign in: \(error)")
            } else {
                UserManager.shared.current = user
//                guard let controller = self?.storyboard?.instantiateViewController(identifier: "TokenResult") as? TokenResultViewController else { return }
//                controller.client = self?.signin?.idx
//                controller.token = user?.token
//                self?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}