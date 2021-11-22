/*
 * Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

extension IDXClient.Response {
    internal convenience init(client: IDXClientAPI, v1 response: V1.Response) throws {
        let authenticators = try IDXClient.AuthenticatorCollection(client: client, v1: response)
        let remediations = IDXClient.RemediationCollection(client: client, v1: response)
        let successRemediationOption = IDXClient.Remediation(client: client, v1: response.successWithInteractionCode)
        let messages = IDXClient.MessageCollection(messages: response.messages?.value.compactMap { IDXClient.Message(client: client, v1: $0) },
                                                   nestedMessages: remediations.nestedMessages())
        
        self.init(client: client,
                  expiresAt: response.expiresAt,
                  intent: Intent(string: response.intent),
                  authenticators: authenticators,
                  remediations: remediations,
                  successRemediationOption: successRemediationOption,
                  messages: messages,
                  app: IDXClient.Application(v1: response.app?.value),
                  user: IDXClient.User(v1: response.user?.value))

        try loadRelatedObjects()
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
        guard let object = object,
              let userId = object.id
        else { return nil }
        self.init(id: userId)
    }
}

extension V1.Response {
    struct AuthenticatorMapping {
        let jsonPath: String
        let authenticator: V1.Response.Authenticator
    }

    func authenticatorState(for authenticators: [Authenticator],
                            in jsonPaths: [String]) -> IDXClient.Authenticator.State
    {
        var state = [IDXClient.Authenticator.State]()
        state = jsonPaths.reduce(into: state, { state, jsonPath in
            switch jsonPath {
            case "$.currentAuthenticatorEnrollment":
                state.append(.enrolling)
                
            case "$.currentAuthenticator":
                state.append(.authenticating)
                
            case "$.recoveryAuthenticator":
                state.append(.recovery)
                
            default:
                if jsonPath.hasPrefix("$.authenticatorEnrollments") {
                    state.append(.enrolled)
                }
                
                else if jsonPath.hasPrefix("$.authenticators") {
                    state.append(.normal)
                }
            }
        })
        
        return state.sorted(by: { $0.rawValue > $1.rawValue }).first ?? .normal
    }
    
    func allAuthenticators() -> [AuthenticatorMapping] {
        var allAuthenticators: [AuthenticatorMapping] = []
        if let authenticator = currentAuthenticatorEnrollment?.value {
            allAuthenticators.append(.init(jsonPath: "$.currentAuthenticatorEnrollment",
                                           authenticator: authenticator))
        }
        
        if let authenticator = currentAuthenticator?.value {
            allAuthenticators.append(.init(jsonPath: "$.currentAuthenticator",
                                           authenticator: authenticator))
        }
        
        if let authenticator = recoveryAuthenticator?.value {
            allAuthenticators.append(.init(jsonPath: "$.recoveryAuthenticator",
                                           authenticator: authenticator))
        }
        
        if let authenticators = authenticatorEnrollments?.value,
           !authenticators.isEmpty
        {
            for index in 0 ... authenticators.count - 1 {
                allAuthenticators.append(.init(jsonPath: "$.authenticatorEnrollments.value[\(index)]",
                                               authenticator: authenticators[index]))
            }
        }
        
        if let authenticators = authenticators?.value,
           !authenticators.isEmpty
        {
            for index in 0 ... authenticators.count - 1 {
                allAuthenticators.append(.init(jsonPath: "$.authenticators.value[\(index)]",
                                               authenticator: authenticators[index]))
            }
        }

        return allAuthenticators
    }
}

extension Capability.PasswordSettings {
    init?(with settings: [String:JSONValue]?) {
        guard let settings = settings,
              let complexity = settings["complexity"]?.toAnyObject() as? [String: Any]
        else { return nil }
        
        self.init(daysToExpiry: settings["daysToExpiry"]?.numberValue() as? Int ?? 0,
                  minLength: complexity["minLength"] as? Int ?? 0,
                  minLowerCase: complexity["minLowerCase"] as? Int ?? 0,
                  minUpperCase: complexity["minUpperCase"] as? Int ?? 0,
                  minNumber: complexity["minNumber"] as? Int ?? 0,
                  minSymbol: complexity["minSymbol"] as? Int ?? 0,
                  excludeUsername: complexity["excludeUsername"] as? Bool ?? false,
                  excludeAttributes: complexity["excludeAttributes"] as? [String] ?? [])
    }
}

extension IDXClient.AuthenticatorCollection {
    convenience init(client: IDXClientAPI, v1 object: V1.Response) throws {
        let authenticatorMapping: [String:[V1.Response.AuthenticatorMapping]]
        authenticatorMapping = object
            .allAuthenticators()
            .reduce(into: [:]) { (result, mapping) in
                let authenticatorType = "\(mapping.authenticator.type):\(mapping.authenticator.id ?? "-")"
                var collection: [V1.Response.AuthenticatorMapping] = result[authenticatorType] ?? []
                collection.append(mapping)
                result[authenticatorType] = collection
            }
        
        let authenticators: [IDXClient.Authenticator] = try authenticatorMapping
            .values
            .compactMap({ (mappingArray) in
                return try IDXClient.Authenticator.makeAuthenticator(client: client,
                                                                     v1: mappingArray.map { $0.authenticator },
                                                                     jsonPaths: mappingArray.map { $0.jsonPath },
                                                                     in: object)
            })
        
        self.init(authenticators: authenticators)
    }
}

extension IDXClient.RemediationCollection {
    convenience init(client: IDXClientAPI, v1 object: V1.Response?) {
        var remediations: [IDXClient.Remediation] = object?.remediation?.value.compactMap { (value) in
            IDXClient.Remediation.makeRemediation(client: client, v1: value)
        } ?? []
        
        if let cancelResponse = IDXClient.Remediation.makeRemediation(client: client, v1: object?.cancel) {
            remediations.append(cancelResponse)
        }

        if let successResponse = IDXClient.Remediation.makeRemediation(client: client, v1: object?.successWithInteractionCode) {
            remediations.append(successResponse)
        }
        
        self.init(remediations: remediations)
    }
}

extension Capability.Sendable {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let authenticator = authenticators.compactMap({ $0.send }).first,
              let remediation = IDXClient.Remediation.makeRemediation(client: client, v1: authenticator)
        else {
            return nil
        }
        self.init(client: client, remediation: remediation)
    }
}

extension Capability.Resendable {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let authenticator = authenticators.compactMap({ $0.resend }).first,
              let remediation = IDXClient.Remediation.makeRemediation(client: client, v1: authenticator)
        else {
            return nil
        }
        self.init(client: client, remediation: remediation)
    }
}

extension Capability.Recoverable {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let authenticator = authenticators.compactMap({ $0.recover }).first,
              let remediation = IDXClient.Remediation.makeRemediation(client: client, v1: authenticator)
        else {
            return nil
        }
        self.init(client: client, remediation: remediation)
    }
}

extension Capability.Pollable {
    convenience init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let typeName = authenticators.first?.type,
              let authenticator = authenticators.compactMap({ $0.poll }).first,
              let remediation = IDXClient.Remediation.makeRemediation(client: client, v1: authenticator)
        else {
            return nil
        }
        
        let type = IDXClient.Authenticator.Kind(string: typeName)
        self.init(client: client,
                  authenticatorType: type,
                  remediation: remediation)
    }

    convenience init?(client: IDXClientAPI, v1 form: V1.Response.Form) {
        guard form.name == "enroll-poll" ||
                form.name == "challenge-poll"
        else {
            return nil
        }
        guard let remediation = IDXClient.Remediation.makeRemediation(client: client,
                                                                      v1: form,
                                                                      createCapabilities: false)
        else {
            return nil
        }
        
        self.init(client: client,
                  authenticatorType: .app,
                  remediation: remediation)
    }
}

extension Capability.NumberChallenge {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let answer = authenticators.compactMap({ $0.contextualData?["correctAnswer"] }).first?.stringValue()
        else {
            return nil
        }
        
        self.init(correctAnswer: answer)
    }
}

extension Capability.Profile {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let profile = authenticators.compactMap({ $0.profile }).first
        else {
            return nil
        }
        
        self.init(profile: profile)
    }
}

extension Capability.PasswordSettings {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        guard let typeName = authenticators.first?.type,
              IDXClient.Authenticator.Kind(string: typeName) == .password,
              let settings = authenticators.compactMap({ $0.settings }).first
        else {
            return nil
        }
        
        self.init(with: settings)
    }
}

extension Capability.OTP {
    init?(client: IDXClientAPI, v1 authenticators: [V1.Response.Authenticator]) {
        let methods = methodTypes(from: authenticators)
        guard methods.contains(.otp) || methods.contains(.totp)
        else {
            return nil
        }
        
        guard let typeName = authenticators.first?.type else { return nil }
        let type = IDXClient.Authenticator.Kind(string: typeName)
        
        guard type == .app,
              let contextualData = authenticators.compactMap({ $0.contextualData }).first,
              let qrcode = contextualData["qrcode"]?.toAnyObject() as? [String:String],
              qrcode["method"] == "embedded",
              let mimeType = qrcode["type"],
              let imageUrlString = qrcode["href"],
              let imageData = imageUrlString.base64ImageData
        else {
            return nil
        }
        
        let sharedSecret = contextualData["sharedSecret"]?.stringValue()

        self.init(mimeType: mimeType,
                  imageData: imageData,
                  sharedSecret: sharedSecret)
    }
}

extension Capability.SocialIDP {
    init?(client: IDXClientAPI, v1 object: V1.Response.Form) {
        let type = IDXClient.Remediation.RemediationType(string: object.name)
        guard type == .redirectIdp,
              let idpObject = object.idp,
              let idpId = idpObject["id"],
              let idpName = idpObject["name"],
              let idpType = object.type
        else {
            return nil
        }

        self.init(client: client,
                  redirectUrl: object.href,
                  id: idpId,
                  idpName: idpName,
                  idpType: idpType,
                  service: .init(string: idpType))
    }
}

private func methodTypes(from authenticators: [V1.Response.Authenticator]) -> [IDXClient.Authenticator.Method]
{
    let methods = authenticators
        .compactMap { $0.methods }
        .reduce(into: [String:String]()) { (partialResult, items: [[String:String]]) in
            items.forEach { item in
                item.forEach { (key: String, value: String) in
                    partialResult[key] = value
                }
            }
        }
    let methodTypes: [IDXClient.Authenticator.Method] = methods
        .filter { (key, value) in
            key == "type"
        }
        .map { (key, value) in
            return IDXClient.Authenticator.Method(string: value)
        }
    return methodTypes
}

extension IDXClient.Authenticator {
    static func makeAuthenticator(client: IDXClientAPI,
                                  v1 authenticators: [V1.Response.Authenticator],
                                  jsonPaths: [String],
                                  in response: V1.Response) throws -> IDXClient.Authenticator?
    {
        guard let first = authenticators.first else { return nil }

        let filteredTypes = Set(authenticators.map({ $0.type }))
        guard filteredTypes.count == 1 else {
            throw IDXClientError.internalMessage("Some mapped authenticators have differing types: \(filteredTypes.joined(separator: ", "))")
        }
        
        let state = response.authenticatorState(for: authenticators, in: jsonPaths)
        let key = authenticators.compactMap { $0.key }.first
        let methods = authenticators.compactMap { $0.methods }.first

        let capabilities: [AuthenticatorCapability?] = [
            Capability.Profile(client: client, v1: authenticators),
            Capability.Sendable(client: client, v1: authenticators),
            Capability.Resendable(client: client, v1: authenticators),
            Capability.Pollable(client: client, v1: authenticators),
            Capability.Recoverable(client: client, v1: authenticators),
            Capability.PasswordSettings(client: client, v1: authenticators),
            Capability.NumberChallenge(client: client, v1: authenticators),
            Capability.OTP(client: client, v1: authenticators)
        ]
        
        return IDXClient.Authenticator(client: client,
                                       v1JsonPaths: jsonPaths,
                                       state: state,
                                       id: first.id,
                                       displayName: first.displayName,
                                       type: first.type,
                                       key: key,
                                       methods: methods,
                                       capabilities: capabilities.compactMap { $0 })
    }
}

extension IDXClient.Remediation {
    static func makeRemediation(client: IDXClientAPI,
                                v1 object: V1.Response.Form?,
                                createCapabilities: Bool = true) -> IDXClient.Remediation?
    {
        guard let object = object else { return nil }
        let form = Form(fields: object.value?.map({ (value) in
          .init(client: client, v1: value)
        })) ?? Form(fields: [])!
        let refresh = (object.refresh != nil) ? Double(object.refresh!) / 1000.0 : nil
        
        let capabilities: [RemediationCapability?] = createCapabilities ? [
            Capability.SocialIDP(client: client, v1: object),
            Capability.Pollable(client: client, v1: object)
        ] : []
        
        return IDXClient.Remediation(client: client,
                                     name: object.name,
                                     method: object.method,
                                     href: object.href,
                                     accepts: object.accepts,
                                     form: form,
                                     refresh: refresh,
                                     relatesTo: object.relatesTo,
                                     capabilities: capabilities.compactMap { $0 })
    }

    internal convenience init?(client: IDXClientAPI, v1 object: V1.Response.Form?) {
        guard let object = object,
              let form = Form(fields: object.value?.map({ (value) in
                .init(client: client, v1: value)
              }))
        else { return nil }

        self.init(client: client,
                  name: object.name,
                  method: object.method,
                  href: object.href,
                  accepts: object.accepts,
                  form: form,
                  refresh: (object.refresh != nil) ? Double(object.refresh!) / 1000.0 : nil,
                  relatesTo: object.relatesTo,
                  capabilities: [])
    }
}

extension IDXClient.Remediation.Form.Field {
    internal convenience init(client: IDXClientAPI, v1 object: V1.Response.FormValue) {
        // Fields default to visible, except there are circumstances where
        // fields (such as `id`) don't properly include a `visible: false`. As a result,
        // we need to infer visibility from other values.
        var visible = object.visible ?? true
        if let isMutable = object.mutable,
           !isMutable && object.value != nil
        {
            visible = false
        }
        
        self.init(name: object.name,
                  label: object.label,
                  type: object.type,
                  value: object.value?.toAnyObject(),
                  visible: visible,
                  mutable: object.mutable ?? true,
                  required: object.required ?? false,
                  secret: object.secret ?? false,
                  relatesTo: object.relatesTo,
                  form: IDXClient.Remediation.Form(fields: object.form?.value.map({ (value) in
                    .init(client: client, v1: value)
                  })),
                  options: object.options?.map { (value) in
                    .init(client: client, v1: value)
                  },
                  messages: .init(messages: object.messages?.value.compactMap {
                    IDXClient.Message(client: client, v1: $0)
                  }))
        self.messages.allMessages.forEach { $0.field = self }
    }
}

extension IDXClient.Token {
    internal convenience init(v1 object: V1.Token, configuration: IDXClient.Configuration) {
        self.init(accessToken: object.accessToken,
                  refreshToken: object.refreshToken,
                  expiresIn: TimeInterval(object.expiresIn),
                  idToken: object.idToken,
                  scope: object.scope,
                  tokenType: object.tokenType,
                  configuration: configuration)
    }
}
