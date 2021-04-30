/*
 * Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation

typealias V1 = IDXClient.APIVersion1

protocol IDXContainsRelatableObjects {
    typealias RelatesTo = IDXClient.APIVersion1.Response.RelatesTo
    func nestedRelatableObjects() -> [IDXHasRelatedObjects]

    func find(relatesTo: IDXClient.APIVersion1.Response.RelatesTo?,
              root: IDXContainsRelatableObjects) -> AnyObject?
    func find(relatesTo: [IDXClient.APIVersion1.Response.RelatesTo]?,
              root: IDXContainsRelatableObjects) -> [AnyObject]?
}

extension IDXContainsRelatableObjects {
    func find(relatesTo: IDXClient.APIVersion1.Response.RelatesTo?,
              root: IDXContainsRelatableObjects) -> AnyObject?
    {
        guard let relatesTo = relatesTo else { return nil }
        var result: AnyObject? = self as AnyObject
        for item in relatesTo.path {
            switch item {
            case .root:
                result = root as AnyObject
            case .property(name: let name):
                if result?.responds(to: Selector(name)) ?? false,
                    let object = result?.value(forKey: name) {
                    result = object as AnyObject
                }
            case .array(index: let index):
                if let array = result as? Array<AnyObject> {
                    result = array[index]
                }
            }
        }
        return result
    }
    
    func find(relatesTo: [IDXClient.APIVersion1.Response.RelatesTo]?,
              root: IDXContainsRelatableObjects) -> [AnyObject]?
    {
        guard let relatesTo = relatesTo else { return nil }
        return relatesTo.compactMap { find(relatesTo: $0, root: root) }
    }
}

protocol IDXHasRelatedObjects: IDXContainsRelatableObjects {
    func findRelatedObjects(from root: IDXContainsRelatableObjects)
}

extension IDXClient.Response: IDXContainsRelatableObjects {
    internal convenience init(client: IDXClientAPI, v1 response: V1.Response) throws {
        self.init(client: client,
                  expiresAt: response.expiresAt,
                  intent: Intent(string: response.intent),
                  authenticators: try .init(client: client, v1: response),
                  remediations: .init(client: client, v1: response),
                  messages: response.messages?.value.compactMap { IDXClient.Message(client: client, v1: $0) },
                  app: IDXClient.Application(v1: response.app?.value),
                  user: IDXClient.User(v1: response.user?.value))

        nestedRelatableObjects().forEach { (object) in
            object.findRelatedObjects(from: self)
        }
    }
    
    func nestedRelatableObjects() -> [IDXHasRelatedObjects] {
        var result: [IDXHasRelatedObjects] = []
//        result.append(contentsOf: remediation?.nestedRelatableObjects() ?? [])
//        result.append(contentsOf: cancelRemediationOption?.nestedRelatableObjects() ?? [])
//        result.append(contentsOf: successResponse?.nestedRelatableObjects() ?? [])
        return result
    }
}

extension IDXClient.Message {
    internal convenience init?(client: IDXClientAPI, v1 object: V1.Response.Message?) {
        guard let object = object else { return nil }
        self.init(type: object.type,
                  localizationKey: object.i18n?.key,
                  message: object.message)
    }
}

extension IDXClient.Application {
    internal convenience init?(v1 object: V1.Response.App?) {
        guard let object = object else { return nil }
        self.init(id: object.id,
                  label: object.label,
                  name: object.name)
    }
}

extension IDXClient.User {
    internal convenience init?(v1 object: V1.Response.User?) {
        guard let object = object else { return nil }
        self.init(id: object.id)
    }
}

extension V1.Response {
    func authenticatorState(for authenticatorId: String) -> IDXClient.Authenticator.State {
        if currentAuthenticatorEnrollment?.value.id == authenticatorId {
            return .enrolling
        }
        
        else if currentAuthenticator?.value.id == authenticatorId {
            return .authenticating
        }
        
        else if authenticatorEnrollments?.value.first(where: { (authenticator) -> Bool in
            authenticator.id == authenticatorId
        }) != nil {
            return .enrolled
        }
        
        else {
            return .normal
        }
    }
    
    func allAuthenticators() -> [Authenticator] {
        var allAuthenticators: [V1.Response.Authenticator] = []
        if let authenticator = currentAuthenticatorEnrollment?.value {
            allAuthenticators.append(authenticator)
        }
        if let authenticator = currentAuthenticator?.value {
            allAuthenticators.append(authenticator)
        }
        if let authenticator = recoveryAuthenticator?.value {
            allAuthenticators.append(authenticator)
        }
        if let authenticators = authenticatorEnrollments?.value {
            allAuthenticators.append(contentsOf: authenticators)
        }
        if let authenticators = authenticators?.value {
            allAuthenticators.append(contentsOf: authenticators)
        }

        return allAuthenticators
    }
}

extension IDXClient.Authenticator.Password.Settings {
    convenience init?(with settings: [String:JSONValue]?) {
        guard let settings = settings,
              let complexity = settings["complexity"]?.toAnyObject() as? [String: JSONValue]
        else { return nil }
        
        self.init(daysToExpiry: settings["daysToExpiry"]?.numberValue()?.intValue ?? 0,
                  minLength: complexity["minLength"]?.numberValue()?.intValue ?? 0,
                  minLowerCase: complexity["minLowerCase"]?.numberValue()?.intValue ?? 0,
                  minUpperCase: complexity["minUpperCase"]?.numberValue()?.intValue ?? 0,
                  minNumber: complexity["minNumber"]?.numberValue()?.intValue ?? 0,
                  minSymbol: complexity["minSymbol"]?.numberValue()?.intValue ?? 0,
                  excludeUsername: complexity["excludeUsername"]?.numberValue()?.boolValue ?? false,
                  excludeAttributes: complexity["excludeAttributes"]?.toAnyObject() as? [String] ?? [])
    }
}

extension IDXClient.AuthenticatorCollection {
    convenience init(client: IDXClientAPI, v1 object: V1.Response) throws {
        let authenticatorMapping: [String:[V1.Response.Authenticator]] = object
            .allAuthenticators()
            .reduce(into: [:]) { (result, authenticator) in
                var collection: [V1.Response.Authenticator] = result[authenticator.type] ?? []
                collection.append(authenticator)
                result[authenticator.type] = collection
            }
        
        let authenticators: [IDXClient.Authenticator.Kind: IDXClient.Authenticator] = try authenticatorMapping
            .values
            .reduce(into: [:]) { (result, authenticatorArray) in
                guard let authenticator = try IDXClient.Authenticator.makeAuthenticator(client: client,
                                                                                        v1: authenticatorArray,
                                                                                        in: object)
                else { return }
                result[authenticator.type] = authenticator
            }
        
        self.init(authenticators: authenticators)
    }
}

extension IDXClient.RemediationCollection {
    convenience init(client: IDXClientAPI, v1 object: V1.Response?) {
        var remediations: [IDXClient.Remediation] = object?.remediation?.value.compactMap { (value) in
            IDXClient.Remediation(client:client, v1: value)
        } ?? []
        
        if let cancelResponse = IDXClient.Remediation(client: client, v1: object?.cancel) {
            remediations.append(cancelResponse)
        }

        if let successResponse = IDXClient.Remediation(client: client, v1: object?.successWithInteractionCode) {
            remediations.append(successResponse)
        }
        
        self.init(remediations: remediations)
    }
    
    convenience init(remediations: [IDXClient.Remediation]) {
        self.init(remediations: remediations.reduce(into: [:], { (result, remediation) in
            result[remediation.name] = remediation
        }))
    }
}
    
//extension IDXClient.Remediation: IDXContainsRelatableObjects {
//    internal convenience init?(client: IDXClientAPI, v1 object: V1.Response.IonCollection<V1.Response.Form>?) {
//        guard let object = object,
//              let type = object.type
//        else {
//            return nil
//        }
//        self.init(client: client,
//                  type: type,
//                  remediationOptions: object.value.compactMap { (value) in
//                    IDXClient.Remediation(client: client, v1: value)
//                  })
//    }
//
//    func nestedRelatableObjects() -> [IDXHasRelatedObjects] {
//        return remediationOptions.flatMap { $0.nestedRelatableObjects() }
//    }
//}

extension IDXClient.Authenticator {
    static func makeAuthenticator(client: IDXClientAPI,
                                  v1 authenticators: [V1.Response.Authenticator],
                                  in response: V1.Response) throws -> IDXClient.Authenticator?
    {
        guard let first = authenticators.first else { return nil }

        let filteredTypes = Set(authenticators.map({ $0.type }))
        guard filteredTypes.count == 1 else {
            throw IDXClientError.internalError(message: "Some mapped authenticators have differing types: \(filteredTypes.joined(separator: ", "))")
        }
        
        let type = IDXClient.Authenticator.Kind(string: first.type)
        let state = response.authenticatorState(for: first.id)
        let key = authenticators.compactMap { $0.key }.first
        let methods = authenticators.compactMap { $0.methods }.first
        let settings = authenticators.compactMap { $0.settings }.first
        let profile = authenticators.compactMap { $0.profile }.first
        let contextualData = authenticators.compactMap { $0.contextualData }.first
        let sendOption = IDXClient.Remediation(client: client, v1: authenticators.compactMap { $0.send }.first )
        let resendOption = IDXClient.Remediation(client: client, v1: authenticators.compactMap { $0.resend }.first)
        let pollOption = IDXClient.Remediation(client: client, v1: authenticators.compactMap { $0.poll }.first)

        switch type {
        case .password:
            let password = IDXClient.Authenticator.Password.Settings(with: settings)
            return IDXClient.Authenticator.Password(client: client,
                                                    state: state,
                                                    id: first.id,
                                                    displayName: first.displayName,
                                                    type: first.type,
                                                    key: key,
                                                    methods: methods,
                                                    settings: password)
            
        case .phone:
            return IDXClient.Authenticator.Phone(client: client,
                                                 state: state,
                                                 id: first.id,
                                                 displayName: first.displayName,
                                                 type: first.type,
                                                 key: key,
                                                 methods: methods,
                                                 profile: profile,
                                                 sendOption: sendOption,
                                                 resendOption: resendOption)
            
        case .email:
            return IDXClient.Authenticator.Email(client: client,
                                                 state: state,
                                                 id: first.id,
                                                 displayName: first.displayName,
                                                 type: first.type,
                                                 key: key,
                                                 methods: methods,
                                                 profile: profile,
                                                 resendOption: resendOption,
                                                 pollOption: pollOption)

        default:
            return IDXClient.Authenticator(client: client,
                                           state: state,
                                           id: first.id,
                                           displayName: first.displayName,
                                           type: first.type,
                                           key: key,
                                           methods: methods)
        }
    }
}

extension IDXClient.Remediation: IDXHasRelatedObjects {
    static func makeRemediation(client: IDXClientAPI,
                                v1 object: V1.Response.Form?) -> IDXClient.Remediation?
    {
        guard let object = object else { return nil }
        let form = Form(fields: object.value?.map({ (value) in
            .init(client: client, v1: value)
        }))
        let refresh = (object.refresh != nil) ? Double(object.refresh!) / 1000.0 : nil
        
        let type = IDXClient.Remediation.RemediationType(string: object.name)
        switch type {
        case .redirectIdp:
            guard let idpObject = object.idp,
                  let idpId = idpObject["id"],
                  let idpName = idpObject["name"],
                  let idpType = object.type
            else { return nil }

            return IDXClient.Remediation.SocialAuth(client: client,
                                                    name: object.name,
                                                    method: object.method,
                                                    href: object.href,
                                                    accepts: object.accepts,
                                                    form: form,
                                                    refresh: refresh,
                                                    id: idpId,
                                                    idpName: idpName,
                                                    service: .init(string: idpType))
        default:
            return IDXClient.Remediation(client: client, v1: object)
        }
    }

    internal convenience init?(client: IDXClientAPI, v1 object: V1.Response.Form?) {
        guard let object = object else { return nil }

        self.init(client: client,
                  name: object.name,
                  method: object.method,
                  href: object.href,
                  accepts: object.accepts,
                  form: Form(fields: object.value?.map({ (value) in
                    .init(client: client, v1: value)
                  })),
                  refresh: (object.refresh != nil) ? Double(object.refresh!) / 1000.0 : nil)
    }

    func nestedRelatableObjects() -> [IDXHasRelatedObjects] {
//        var result = form.flatMap { $0.nestedRelatableObjects() }
//        result.append(self)
//        return result
        return []
    }

    func findRelatedObjects(from root: IDXContainsRelatableObjects) {
//        relatesTo = find(relatesTo: v1RelatesTo, root: root)
    }
}

extension IDXClient.Remediation.Form.Field: IDXHasRelatedObjects {
    internal convenience init(client: IDXClientAPI, v1 object: V1.Response.FormValue) {
        self.init(name: object.name,
                  label: object.label,
                  type: object.type,
                  value: object.value?.toAnyObject(),
                  visible: object.visible ?? (object.label != nil),
                  mutable: object.mutable ?? true,
                  required: object.required ?? false,
                  secret: object.secret ?? false,
                  form: IDXClient.Remediation.Form(fields: object.form?.value.map({ (value) in
                    .init(client: client, v1: value)
                  })),
                  options: object.options?.map {
                    IDXClient.Remediation.Form(fields: $0.form?.value.map({ (value) in
                      .init(client: client, v1: value)
                    }))
                  },
                  messages: object.messages?.value.compactMap {
                    IDXClient.Message(client: client, v1: $0)
                  })
    }

    func nestedRelatableObjects() -> [IDXHasRelatedObjects] {
        var result: [IDXHasRelatedObjects] = [self]
//        result.append(contentsOf: form?.flatMap { $0.nestedRelatableObjects() } ?? [])
//        result.append(contentsOf: options?.flatMap { $0.nestedRelatableObjects() } ?? [])
        return result
    }

    func findRelatedObjects(from root: IDXContainsRelatableObjects) {
//        relatesTo = find(relatesTo: v1RelatesTo, root: root)
    }
}

extension IDXClient.Token {
    internal convenience init(v1 object: V1.Token) {
        self.init(accessToken: object.accessToken,
                  refreshToken: object.refreshToken,
                  expiresIn: TimeInterval(object.expiresIn),
                  idToken: object.idToken,
                  scope: object.scope,
                  tokenType: object.tokenType)
    }
}
