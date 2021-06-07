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

import Foundation
import OktaSdk
import XCTest

struct Scenario {
    let category: Category
    let configuration: Configuration
    let validator: ScenarioValidator

    private static var sharedProfileId: String? = ProcessInfo.processInfo.environment["A18N_PROFILE_ID"]
    private(set) var credentials: Credentials?
    private(set) var profile: A18NProfile? {
        didSet {
            guard let emailAddress = profile?.emailAddress else {
                return
            }
            
            credentials = .init(username: emailAddress,
                                password: "Abcd1234",
                                firstName: "Mary",
                                lastName: "Tester")
        }
    }
    
    init(_ category: Category, configuration: Configuration? = nil) throws {
        self.configuration = try configuration ?? Configuration()
        self.category = category
        
        OktaClient.configuration = OktaConfiguration(apiKey: self.configuration.oktaApiKey,
                                                     domain: self.configuration.oktaDomain)
        OktaClient.queue = DispatchQueue.init(label: "OktaManagementSdk", attributes: .concurrent)
        
        validator = category.validator
    }
    
    mutating func setUp() throws {
        let group = DispatchGroup()
        group.enter()
        
        // Create / load the A18N Profile
        var profile: A18NProfile?
        var error: Swift.Error?
        if let profileId = Scenario.sharedProfileId,
           !profileId.isEmpty
        {
            XCTContext.runActivity(named: "Load existing A18N Profile") { _ in
                A18NProfile.loadProfile(using: configuration.a18nApiKey, profileId: profileId) {
                    profile = $0
                    error = $1
                    
                    group.leave()
                }
            }
        } else {
            XCTContext.runActivity(named: "Create A18N Profile") { _ in
                A18NProfile.createProfile(using: configuration.a18nApiKey) {
                    profile = $0
                    error = $1
                    
                    group.leave()
                }
            }
        }
        group.wait()
        
        guard profile != nil else {
            throw(error ?? Error.cannotCreateA18NProfile)
        }

        self.profile = profile
        Scenario.sharedProfileId = profile?.profileId

        // Configure the org
        group.enter()
        XCTContext.runActivity(named: "Configuring the org for the \(category) scenario category") { _ in
            validator.configure {
                error = $0
                group.leave()
            }
        }
        group.wait()
        
        if let error = error {
            throw error
        }
    }
    
    func tearDown() throws {
        let group = DispatchGroup()
        
        var errors = [Swift.Error]()
        XCTContext.runActivity(named: "Tearing down test configuration") { _ in
            if let credentials = credentials {
                group.enter()
                XCTContext.runActivity(named: "Deleting test user \(credentials.username)") { _ in
                    validator.deleteUser(username: credentials.username) { (error) in
                        if let error = error {
                            errors.append(error)
                        }
                        group.leave()
                    }
                }
            }
            
            if let profile = profile {
                group.enter()
                XCTContext.runActivity(named: "Deleting A18N profile") { _ in
                    profile.delete(using: configuration.a18nApiKey) { (error) in
                        if let error = error {
                            errors.append(error)
                        }
                        group.leave()
                    }
                }
            }
        }
        group.wait()
        
        if !errors.isEmpty,
           let error = errors.first
        {
            throw error
        }
    }
    
    func createUser() throws {
        guard let credentials = credentials else {
            throw Error.profileValuesInvalid
        }
        
        let group = DispatchGroup()
        group.enter()
        
        var error: Swift.Error?
        XCTContext.runActivity(named: "Creating test user \(credentials.username)") { _ in
            validator.createUser(username: credentials.username,
                                 password: credentials.password,
                                 firstName: credentials.firstName,
                                 lastName: credentials.lastName)
            {
                error = $0
                group.leave()
            }
        }
        group.wait()

        if let error = error {
            throw error
        }
    }

    func deleteUser() throws {
        guard let credentials = credentials else {
            throw Error.profileValuesInvalid
        }
        
        let group = DispatchGroup()
        group.enter()
        
        var error: Swift.Error?
        XCTContext.runActivity(named: "Deleting test user \(credentials.username)") { _ in
            validator.deleteUser(username: credentials.username) {
                error = $0
                group.leave()
            }
        }
        group.wait()

        if let error = error {
            if let error = error as? OktaSdk.ErrorResponse {
                switch error {
                case .error(let code, _, _, _):
                    if code == 404 {
                        return
                    }
                }
            }
            
            throw error
        }
    }
    
    func receive(code type: A18NProfile.MessageType, timeout: TimeInterval = 30, pollInterval: TimeInterval = 1) throws -> String {
        guard let profile = profile else {
            throw Error.noA18NProfile
        }
        
        var receiver: CodeReceiver!
        switch type {
        case .email:
            receiver = EmailCodeReceiver(profile: profile)
        case .sms:
            receiver = SMSReceiver(profile: profile)
        case .voice:
            receiver = VoiceReceiver(profile: profile)
        }
        
        var result: String?
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            receiver.waitForCode(timeout: timeout, pollInterval: pollInterval) { (code) in
                result = code
                group.leave()
            }
        }
        group.wait()
        
        guard result != nil,
              result != ""
        else {
            throw Error.noVerificationCodeReceived
        }
        
        return result!
    }

    struct Credentials {
        let username: String
        let password: String
        let firstName: String
        let lastName: String
    }
    
    enum Category {
        case passcodeOnly
        case selfServiceRegistration
    }
    
    enum Error: Swift.Error {
        case missingClientCredentials
        case cannotCreateA18NProfile
        case profileValuesInvalid
        case noA18NProfile
        case noVerificationCodeReceived
    }
}

protocol ScenarioValidator {
    func configure(completion: @escaping (Error?) -> Void)
    func createUser(username: String,
                    password: String,
                    firstName: String,
                    lastName: String,
                    completion: @escaping (Error?) -> Void)
    func deleteUser(username: String,
                    completion: @escaping (Error?) -> Void)
}

extension Scenario.Category {    
    var validator: ScenarioValidator {
        switch self {
        case .passcodeOnly:
            return PasscodeScenarioValidator()
        case .selfServiceRegistration:
            return SelfServiceRegistrationScenarioValidator()
        }
    }
}
