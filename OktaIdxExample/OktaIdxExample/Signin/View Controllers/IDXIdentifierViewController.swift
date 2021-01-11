//
//  IDXIdentifierViewController.swift
//  OktaIdxExample
//
//  Created by Mike Nachbaur on 2021-01-08.
//

import UIKit
import OktaIdx
import Combine

/// Sign in controller used for responding to the "identify" remediation option to collect a user's username.
class IDXIdentifierViewController: UIViewController, IDXRemediationController {
    var signin: Signin?
    var response: IDXClient.Response?
    var remediationOption: IDXClient.Remediation.Option?
    
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var identifierField: UITextField!
    @IBOutlet weak var rememberMeLabel: UILabel!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var continueButton: UIButton!
    private var cancelObject: AnyCancellable?
    
    deinit {
        cancelObject?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let form = remediationOption?.form,
              let identifierForm = form.filter({ $0.name == "identifier" }).first,
              let rememberMeForm = form.filter({ $0.name == "rememberMe" }).first else
        {
            showError(SigninError.genericError(message: "Missing expected form fields"))
            return
        }
 
        identifierLabel.text = identifierForm.label
        identifierField.text = identifierForm.value as? String
        rememberMeLabel.text = rememberMeForm.label
        rememberMeSwitch.isOn = rememberMeForm.value as? Bool ?? false
    }
    
    @IBAction func continueAction(_ sender: Any) {
        guard let signin = signin else {
            showError(SigninError.genericError(message: "Signin session deallocated"))
            return
        }

        continueButton.isEnabled = false

        cancelObject = remediationOption?
            .proceed(with: ["identifier": identifierField.text ?? ""])
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
