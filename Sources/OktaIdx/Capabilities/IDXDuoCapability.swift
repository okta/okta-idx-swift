//
//  IDXDuoCapability
//
//
//  Created by Sameh Sayed on 15/11/2023.
//

import Foundation

extension Capability {
    /// Capability to access data related to Duo
    public struct Duo: AuthenticatorCapability,RemediationCapability {
        public let host: String
        public let signedToken: String
        public let script: String
        
        let answerField: Remediation.Form.Field?
    }
}
