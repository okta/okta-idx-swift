//
//  IDXRemediationTableViewController.swift
//  OktaIdxExample
//
//  Created by Mike Nachbaur on 2021-01-13.
//

import UIKit
import OktaIdx
import Combine

class IDXRemediationTableViewController: UITableViewController, IDXResponseController {
    var response: IDXClient.Response?
    var signin: Signin?

    var formSections: [Signin.Section] = []
    let formValues = IDXClient.Remediation.Parameters()
    var chosenRemediationOption: IDXClient.Remediation.FormValue? = nil
    let pollActivityIndicator: UIActivityIndicatorView = {
        let result = UIActivityIndicatorView(style: .medium)
        result.hidesWhenStopped = true
        return result
    }()
    
    private var cancelObject: AnyCancellable?
    
    deinit {
        cancelObject?.cancel()
    }
    
    func rebuildForm() {
        if let response = response {
            formSections = response.remediationForm(delegate: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pollActivityIndicator)
        
        rebuildForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let appTitle = response?.app?.label {
            title = appTitle
        }
        
        navigationController?.setNavigationBarHidden(title?.isEmpty ?? true, animated: animated)

        if let inputView = view.allInputFields().first {
            inputView.becomeFirstResponder()
        }
        
        if let poll = response?.currentAuthenticatorEnrollment?.poll {
            beginPolling(using: poll)
        }
    }
    
    func proceed(to remediationOption: IDXClient.Remediation.Option?, from sender: Any? = nil) {
        guard let signin = signin else {
            showError(SigninError.genericError(message: "Signin session deallocated"))
            return
        }
        
        if let button = sender as? UIButton {
            button.isEnabled = false
        }
        
        cancelObject = remediationOption?
            .proceed(using: formValues)
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
    
    func cancelAction(_ sender: Any?) {
        guard let signin = signin else {
            showError(SigninError.genericError(message: "Signin session deallocated"))
            return
        }

        if let button = sender as? UIButton {
            button.isEnabled = false
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
    
    func beginPolling(using poll: IDXClient.Remediation.Option) {
        guard let refreshTime = poll.refresh else { return }

        if !pollActivityIndicator.isAnimating {
            pollActivityIndicator.startAnimating()
        }
        
        let deadlineTime = DispatchTime.now() + refreshTime
        DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
            poll.proceed(with: [:]) { (response, error) in
                guard let response = response else {
                    return
                }
                
                DispatchQueue.main.async {
                    if let nextPoll = response.currentAuthenticatorEnrollment?.poll {
                        self.beginPolling(using: nextPoll)
                    } else {
                        self.signin?.proceed(to: response)
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return formSections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formSection = formSections[section]
        if formSection.rows.count <= 1 {
            return nil
        }
        
        return formSection.remediationOption?.title
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < formSections.count else { return UITableView.automaticDimension }
        let formSection = formSections[section]

        if formSection.remediationOption?.title != nil {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let formSection = formSections[section]
        return formSection.rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = formSections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.kind.reuseIdentifier, for: indexPath)

        row.configure(cell: cell, at: indexPath)

        return cell
    }
}

extension IDXRemediationTableViewController: SigninRowDelegate {
    func value(for value: IDXClient.Remediation.FormValue) -> Any? {
        return formValues[value]
    }
    
    func row(row: Signin.Row, changedValue: (IDXClient.Remediation.FormValue, Any)) {
        formValues[changedValue.0] = changedValue.1

        if let changedFormValue = changedValue.1 as? IDXClient.Remediation.FormValue {
            if changedFormValue.hasVisibleFields {
                rebuildForm()
            }
            tableView.reloadData()
        }
    }

    func enrollment(action: Signin.EnrollmentAction) {
        var remediationOption: IDXClient.Remediation.Option?
        switch action {
        case .send:
            remediationOption = response?.currentAuthenticatorEnrollment?.send
        case .resend:
            remediationOption = response?.currentAuthenticatorEnrollment?.resend
        case .recover:
            remediationOption = response?.currentAuthenticatorEnrollment?.recover
        }
        
        proceed(to: remediationOption)
    }
    
    func buttonSelected(remediationOption: IDXClient.Remediation.Option?, sender: Any?) {
        if let remediationOption = remediationOption {
            proceed(to: remediationOption, from: sender)
        } else {
            cancelAction(sender)
        }
    }
}

extension Signin.Row.Kind {
    var reuseIdentifier: String {
        switch self {
        case .label(field: _):   return "Label"
        case .message(style: _): return "Message"
        case .text(field: _):    return "Text"
        case .toggle(field: _):  return "Toggle"
        case .option(field: _,
                     option: _): return "Option"
        case .select(field: _,
                     values: _): return "Picker"
        case .button:            return "Button"
        }
    }
}

extension Signin.Row {
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        switch self.kind {
        case .label(field: let field):
            if let cell = cell as? IDXLabelTableViewCell {
                cell.fieldLabel.text = field.label
            }
            
        case .message(style: let style):
            if let cell = cell as? IDXMessageTableViewCell {
                cell.type = style
                cell.update = {
                    switch style {
                    case .enrollment(action: let action):
                        self.delegate?.enrollment(action: action)
                    default: break
                    }
                }
            }
            
        case .text(field: let field):
            if let cell = cell as? IDXTextTableViewCell,
               let fieldName = field.name
            {
                cell.fieldLabel.text = field.label
                cell.fieldLabel.accessibilityIdentifier = "\(fieldName).label"
                cell.textField.isSecureTextEntry = field.secret
                cell.textField.text = (delegate?.value(for: field) ?? field.value as Any) as? String
                cell.textField.accessibilityIdentifier = "\(fieldName).field"
                cell.update = { value in
                    self.delegate?.row(row: self, changedValue: (field, value))
                }
            }
            
        case .toggle(field: let field):
            if let cell = cell as? IDXToggleTableViewCell,
               let fieldName = field.name
             {
                cell.fieldLabel.text = field.label
                cell.fieldLabel.accessibilityIdentifier = "\(fieldName).label"
                cell.switchView.isOn = (delegate?.value(for: field) ?? field.value as Any) as? Bool ?? false
            }
            
        case .option(field: let field, option: let option):
            if let cell = cell as? IDXOptionTableViewCell,
               let fieldName = field.name {
                let currentValue = self.delegate?.value(for: field) as? IDXClient.Remediation.FormValue
                
                if let authenticator = option.relatesTo as? IDXClient.Authenticator,
                   let profile = authenticator.profile
                {
                    cell.detailLabel.text = profile[authenticator.typeName]
                } else {
                    cell.detailLabel.text = nil
                }
                
                cell.fieldLabel.text = option.label
                cell.fieldLabel.accessibilityIdentifier = "\(fieldName).label"
                cell.state = (currentValue == option) ? .checked : .unchecked
                cell.update = {
                    self.delegate?.row(row: self, changedValue: (field, option))
                }
            }
            
        case .button(remediationOption: let option):
            if let cell = cell as? IDXButtonTableViewCell {
                var style = IDXButtonTableViewCell.Style.cancel
                if let option = option {
                    style = .remediation(type: option.type)
                }
                cell.style = style
                cell.buttonView.setTitle(option?.title ?? "Restart", for: .normal)
                cell.update = { (sender, _) in
                    self.delegate?.buttonSelected(remediationOption: option, sender: sender)
                }
            }
            
        case .select(field: let field, values: let values):
            if let cell = cell as? IDXPickerTableViewCell,
               let fieldName = field.name {
                let currentValue = self.delegate?.value(for: field) as? String
                
                cell.fieldLabel.text = field.label
                cell.fieldLabel.accessibilityIdentifier = "\(fieldName).label"
                cell.options = values.compactMap { field in
                    guard let value = field.value as? String,
                          let label = field.label else { return nil }
                    return (value, label)
                }
                cell.selectedValue = currentValue
                cell.update = { value in
                    self.delegate?.row(row: self, changedValue: (field, value))
                }
            }
            
        }
    }
}