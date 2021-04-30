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

extension IDXClient {
    @objc(IDXRemediationCollection)
    public class RemediationCollection: NSObject {
        @objc
        public subscript(name: String) -> Remediation? {
            remediations[name]
        }
        
        public subscript(type: Remediation.RemediationType) -> Remediation? {
            remediations.values.first { $0.type == type }
        }
        
        public typealias DictionaryType = [String: IDXClient.Remediation]
        let remediations: DictionaryType
        init(remediations: DictionaryType?) {
            self.remediations = remediations ?? DictionaryType()

            super.init()
        }
    }
}
