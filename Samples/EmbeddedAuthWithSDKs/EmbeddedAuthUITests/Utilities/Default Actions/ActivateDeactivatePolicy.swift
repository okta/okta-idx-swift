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
import OktaSdk

extension ScenarioValidator {
    func activatePolicy(_ policy: OktaPolicy,
                        completion: @escaping(Error?) -> Void)
    {
        setPolicy(named: policy.rawValue, type: policy.policyType, isActive: true, completion: completion)
    }
    
    func deactivatePolicy(_ policy: OktaPolicy,
                          completion: @escaping(Error?) -> Void)
    {
        setPolicy(named: policy.rawValue, type: policy.policyType, isActive: false, completion: completion)
    }
    
    func deactivatePolicies(_ policies: [OktaPolicy],
                            completion: @escaping(Error?) -> Void)
    {
        var errors: [Error?] = []
        
        for policy in policies {
            deactivatePolicy(policy) { error in
                errors.append(error)
                
                if policy == policies.last {
                    completion(
                        errors.compactMap { $0 }.first
                    )
                }
            }
        }
    }

    private func setPolicy(named: String,
                           type: PolicyType,
                           isActive: Bool,
                           completion: @escaping(Error?) -> Void)
    {
        PolicyAPI.listPolicies(type: type.rawValue) { (policies, error) in
            guard let policies = policies,
                  let policy = policies.first(where: { $0.name == named }),
                  let policyId = policy.id
            else {
                completion(error)
                return
            }
            
            if isActive {
                PolicyAPI.activatePolicy(policyId: policyId) { (_, error) in
                    completion(error)
                }
            } else {
                PolicyAPI.deactivatePolicy(policyId: policyId) { (_, error) in
                    completion(error)
                }
            }
        }
    }
}
