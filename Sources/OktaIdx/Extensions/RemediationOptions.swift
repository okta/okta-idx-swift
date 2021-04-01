//
//  IdentityOption.swift
//  okta-idx-ios
//
//  Created by Mike Nachbaur on 2021-03-15.
//

import Foundation

extension IDXClient.Remediation {
    class Identify: Option {
        func submit(username: String, completion: @escaping (IDXClient.Response?, Error?) -> Void) {
            
        }
    }

    class SelectIdentity: Option {
    }

    class SelectEnrollProfile: Option {
    }

    class ActivateFactor: Option {
    }
    
    class SelectFactorAuthenticate: Option {
    }
    
    class SelectAuthenticatorEnroll: Option {
    }
    
    class SelectEnrollmentChannel: Option {
    }


    case unknown
    case identify
    case selectIdentify
    case selectEnrollProfile
    case cancel
    case activateFactor
    case sendChallenge
    case resendChallenge
    case selectFactorAuthenticate
    case selectFactorEnroll
    case challengeFactor
    case selectAuthenticatorAuthenticate
    case selectAuthenticatorEnroll
    case selectEnrollmentChannel
    case authenticatorVerificationData
    case authenticatorEnrollmentData
    case enrollmentChannelData
    case challengeAuthenticator
    case poll
    case enrollPoll
    case recover
    case enrollFactor
    case enrollAuthenticator
    case reenrollAuthenticator
    case reenrollAuthenticatorWarning
    case resetAuthenticator
    case enrollProfile
    case profileAttributes
    case selectIdp
    case selectPlatform
    case factorPollVerification
    case qrRefresh
    case deviceChallengePoll
    case cancelPolling
    case deviceAppleSsoExtension
    case launchAuthenticator
    case redirect
    case redirectIdp
    case cancelTransaction
    case skip
    case challengePoll

}
