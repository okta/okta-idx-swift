//
//  IDXDuoCapability
//
//
//  Created by Sameh Sayed on 15/11/2023.
//

import Foundation

extension Capability {
    /// Capability to access data related to Duo
    public struct Duo: AuthenticatorCapability {
        public let host: String
        public let signedToken: String
        public let script: String
        public var signatureData: String?
        
        public func willProceed(to remediation: Remediation) {
            guard remediation.authenticators.contains(where: {
                $0.type == .app && $0.methods?.contains(.duo) ?? false
            }),
                  let credentialsField = remediation.form["credentials"],
                  let signatureField = credentialsField.form?.allFields.first(where: { $0.name == "signatureData" })
            else {
                return
            }
            
            signatureField.value = signatureData
        }
    }
}
