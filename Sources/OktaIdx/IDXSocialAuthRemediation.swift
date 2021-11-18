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
/*
extension IDXClient.Remediation {
    /// Remediation subclass used to represent social authentication remediations (e.g. IDP authentication).
    @objc(IDXSocialAuthRemediation)
    public class SocialAuth: IDXClient.Remediation {
        /// The URL an application should load or redirect to in order to continue authentication with the IDP service.
        @objc public var redirectUrl: URL { href }
        
        /// The service for this social authentication remediation.
        @objc public let service: Service
        
        /// The developer-assigned IDP name within the Okta admin dashboard.
        @objc public let idpName: String
        
        
        init?(client: IDXClientAPI,
              name: String,
              method: String,
              href: URL,
              accepts: String?,
              form: IDXClient.Remediation.Form,
              refresh: TimeInterval?,
              relatesTo: [String]?,
              id: String,
              idpName: String,
              idpType: String,
              service: Service)
        {
            self.idpName = idpName
            self.idpType = idpType
            self.service = service
            
            super.init(client: client,
                       name: name,
                       method: method,
                       href: href,
                       accepts: accepts,
                       form: form,
                       refresh: refresh,
                       relatesTo: relatesTo)
        }
        
        public override var description: String {
            let logger = DebugDescription(self)
            let components = [
                "\(#keyPath(redirectUrl)): \(redirectUrl)",
                "\(#keyPath(idpName)): \(idpName)"
            ]
            
            let superDescription = logger.unbrace(super.description)
            
            return logger.brace(superDescription.appending(components.joined(separator: "; ")))
        }
        
        public override var debugDescription: String {
            super.debugDescription
        }
        
        required internal init(client: IDXClientAPI, name: String, method: String, href: URL, accepts: String?, form: Form, refresh: TimeInterval? = nil, relatesTo: [String]? = nil) {
            fatalError("init(client:name:method:href:accepts:form:refresh:relatesTo:) has not been implemented")
        }
    }
}
*/
