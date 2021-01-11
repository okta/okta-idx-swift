//
//  IDXPasscodeViewController.swift
//  OktaIdxExample
//
//  Created by Mike Nachbaur on 2021-01-08.
//

import UIKit
import OktaIdx
import Combine

/// Sign in controller used for responding to the "challenge-authenticator" remediation option to collect a user's password.
class IDXPasscodeViewController: UIViewController, IDXRemediationController {
    var signin: Signin?
    var response: IDXClient.Response?
    var remediationOption: IDXClient.Remediation.Option?

    @IBOutlet weak var passcodeLabel: UILabel!
    @IBOutlet weak var passcodeField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    private var cancelObject: AnyCancellable?
    
    deinit {
        cancelObject?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let form = remediationOption?.form,
              let credentialForm = form.filter({ $0.name == "credentials" }).first,
              let passcodeForm = credentialForm.form?.filter({ $0.name == "passcode" }).first else
        {
            showError(SigninError.genericError(message: "Missing expected form fields"))
            return
        }
 
        passcodeLabel.text = passcodeForm.label
        passcodeField.text = passcodeForm.value as? String
        passcodeField.isSecureTextEntry = passcodeForm.secret
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        guard let signin = signin else {
            showError(SigninError.genericError(message: "Signin session deallocated"))
            return
        }

        cancelObject = response?
            .cancel()
            .receive(on: RunLoop.main)
            .sink { (completion) in
                switch completion {
                case .failure(let error):
                    self.showError(error)
                    signin.failure(with: error)
                case .finished: break
                }
            } receiveValue: { (response) in
                signin.proceed(to: response)
            }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        guard let signin = signin else {
            showError(SigninError.genericError(message: "Signin session deallocated"))
            return
        }
        
        continueButton.isEnabled = false

        cancelObject = remediationOption?
            .proceed(with: ["credentials": ["passcode": passcodeField.text ?? ""]])
            .receive(on: RunLoop.main)
            .sink { (completion) in
                switch completion {
                case .failure(let error):
                    self.showError(error)
                    signin.failure(with: error)
                case .finished: break
                }
            } receiveValue: { (response) in
                signin.proceed(to: response)
            }
    }
}
