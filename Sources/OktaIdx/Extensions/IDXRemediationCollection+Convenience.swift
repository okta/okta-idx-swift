//
// Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

extension IDXClient.RemediationCollection {
    fileprivate typealias SocialAuth = IDXClient.Remediation.SocialAuth
    
    /// User identification remediation for the main login landing page.
    @objc public var identify:                         IDXClient.Remediation.Identify? { self[.identify] as? IDXClient.Remediation.Identify }
    @objc public var identifyRecovery:                 IDXClient.Remediation.Identify? { self[.identifyRecovery] as? IDXClient.Remediation.Identify }
    @objc public var challengeAuthenticator:           IDXClient.Remediation.Challenge? { self[.challengeAuthenticator] as? IDXClient.Remediation.Challenge }

    public var redirectIdp: [IDXClient.Remediation.SocialAuth.Service: IDXClient.Remediation.SocialAuth] {
        let socialRemediations: [SocialAuth] = self.remediations.compactMap { remediation in
            guard remediation.type == .redirectIdp,
                  let socialAuth = remediation as? SocialAuth
            else { return nil }
            return socialAuth
        }
        
        return socialRemediations.reduce(into: [SocialAuth.Service:SocialAuth]()) { result, remediation in
            result[remediation.service] = remediation
        }
    }
    
    @objc public var redirectIdpByName: [String: IDXClient.Remediation.SocialAuth] {
        redirectIdp.values.reduce(into: [String:SocialAuth]()) { result, remediation in
            result[remediation.idpType] = remediation
        }
    }
    
    @objc public var selectAuthenticatorAuthenticate:  IDXClient.Remediation? { self[.selectAuthenticatorAuthenticate] }
    @objc public var selectAuthenticatorEnroll:        IDXClient.Remediation? { self[.selectAuthenticatorEnroll] }
    @objc public var selectEnrollProfile:              IDXClient.Remediation? { self[.selectEnrollProfile] }
    @objc public var selectIdentify:                   IDXClient.Remediation? { self[.selectIdentify] }
    @objc public var selectAuthenticatorUnlockAccount: IDXClient.Remediation? { self[.selectAuthenticatorUnlockAccount] }
    @objc public var selectEnrollmentChannel:          IDXClient.Remediation? { self[.selectEnrollmentChannel] }
    @objc public var authenticatorVerificationData:    IDXClient.Remediation? { self[.authenticatorVerificationData] }
    @objc public var authenticatorEnrollmentData:      IDXClient.Remediation? { self[.authenticatorEnrollmentData] }
    @objc public var enrollmentChannelData:            IDXClient.Remediation? { self[.enrollmentChannelData] }
    @objc public var enrollPoll:                       IDXClient.Remediation? { self[.enrollPoll] }
    @objc public var enrollAuthenticator:              IDXClient.Remediation? { self[.enrollAuthenticator] }
    @objc public var reenrollAuthenticator:            IDXClient.Remediation? { self[.reenrollAuthenticator] }
    @objc public var reenrollAuthenticatorWarning:     IDXClient.Remediation? { self[.reenrollAuthenticatorWarning] }
    @objc public var resetAuthenticator:               IDXClient.Remediation? { self[.resetAuthenticator] }
    @objc public var enrollProfile:                    IDXClient.Remediation? { self[.enrollProfile] }

    /// Self-service account unlock remediation.
    @objc public var unlockAccount:                    IDXClient.Remediation? { self[.unlockAccount] }
    @objc public var deviceChallengePoll:              IDXClient.Remediation? { self[.deviceChallengePoll] }
    @objc public var deviceAppleSsoExtension:          IDXClient.Remediation? { self[.deviceAppleSsoExtension] }
    @objc public var launchAuthenticator:              IDXClient.Remediation? { self[.launchAuthenticator] }
    @objc public var cancelTransaction:                IDXClient.Remediation? { self[.cancelTransaction] }
    
    /// User action used to skip an optional remediation step.
    @objc public var skip:                             IDXClient.Remediation? { self[.skip] }
    @objc public var challengePoll:                    IDXClient.Remediation? { self[.challengePoll] }
    @objc public var consent:                          IDXClient.Remediation? { self[.consent] }
    @objc public var adminConsent:                     IDXClient.Remediation? { self[.adminConsent] }
    @objc public var emailChallengeConsent:            IDXClient.Remediation? { self[.emailChallengeConsent] }
    @objc public var requestActivationEmail:           IDXClient.Remediation? { self[.requestActivationEmail] }

    /// User activation code remediation.
    @objc public var userCode:                         IDXClient.Remediation? { self[.userCode] }
}
