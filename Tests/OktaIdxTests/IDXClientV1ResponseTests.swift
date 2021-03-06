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

import XCTest
@testable import OktaIdx

#if SWIFT_PACKAGE
@testable import TestCommon
#endif

class IDXClientV1ResponseTests: XCTestCase {
    typealias API = IDXClient.APIVersion1
    let clientMock = IDXClientAPIMock(context: .init(configuration: .init(issuer: "https://example.com",
                                                                          clientId: "Bar",
                                                                          clientSecret: nil,
                                                                          scopes: ["scope"],
                                                                          redirectUri: "redirect:/"),
                                                     state: "state",
                                                     interactionHandle: "handle",
                                                     codeVerifier: "verifier"))
    let apiMock = IDXClientAPIv1Mock(configuration: IDXClient.Configuration(issuer: "https://example.com",
                                                                            clientId: "Bar",
                                                                            clientSecret: nil,
                                                                            scopes: ["scope"],
                                                                            redirectUri: "redirect:/"))
    var response: API.Response {
        return try! decode(type: API.Response.self, """
            {
               "cancel" : {
                  "accepts" : "application/json; okta-version=1.0.0",
                  "href" : "https://example.com/idp/idx/cancel",
                  "method" : "POST",
                  "name" : "cancel",
                  "produces" : "application/ion+json; okta-version=1.0.0",
                  "rel" : [
                     "create-form"
                  ],
                  "value" : []
               },
               "expiresAt" : "2021-01-22T19:37:32.000Z",
               "intent" : "LOGIN",
               "stateHandle" : "ahc52KautBHCANs3ScZjLfRcxFjP_N5mqOTYouqHFP",
               "version" : "1.0.0"
            }
        """)
    }

    func testForm() throws {
        let obj = try decode(type: API.Response.Form.self, """
        {
            "rel": ["create-form"],
            "name": "identify",
            "href": "https://example.com/idp/idx/identify",
            "method": "POST",
            "value": [
                {
                    "name": "identifier",
                    "label": "Username"
                }
            ],
            "accepts": "application/ion+json; okta-version=1.0.0"
        }
        """)
        XCTAssertNotNil(obj)
        XCTAssertEqual(obj.rel, ["create-form"])
        XCTAssertEqual(obj.name, "identify")
        XCTAssertEqual(obj.href, URL(string: "https://example.com/idp/idx/identify")!)
        XCTAssertEqual(obj.method, "POST")
        XCTAssertEqual(obj.accepts, "application/ion+json; okta-version=1.0.0")
        
        XCTAssertEqual(try XCTUnwrap(obj.value).count, 1)
    }
    
    func testCompositeForm() throws {
        try decode(type: API.Response.CompositeForm.self, """
        {
          "form": {
            "value": [
              {
                "name": "id",
                "required": true,
                "value": "someCode",
                "mutable": false
              },
              {
                "name": "methodType",
                "required": false,
                "value": 1,
                "mutable": false
              }
            ]
          }
        }
        """) { obj in
            XCTAssertNotNil(obj.form)
            XCTAssertEqual(obj.form.value.count, 2)
            XCTAssertEqual(obj.form.value[0].name, "id")
            XCTAssertEqual(obj.form.value[0].value, .string("someCode"))
            XCTAssertEqual(obj.form.value[1].name, "methodType")
            XCTAssertEqual(obj.form.value[1].value, .number(1))

        }
    }
    
    func testFormValueWithLabel() throws {
        try decode(type: API.Response.FormValue.self, """
        {
            "name": "identifier",
            "label": "Username"
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.name, "identifier")
            XCTAssertEqual(obj.label, "Username")
            XCTAssertNil(obj.type)
            XCTAssertNil(obj.required)
            XCTAssertNil(obj.mutable)
            XCTAssertNil(obj.secret)
            XCTAssertNil(obj.visible)
            XCTAssertNil(obj.value)
        }
    }
    
    func testFormValueWithNoLabel() throws {
        try decode(type: API.Response.FormValue.self, """
        {
            "name": "stateHandle",
            "required": true,
            "value": "theStateHandle",
            "visible": false,
            "secret": false,
            "mutable": false
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.name, "stateHandle")
            XCTAssertNil(obj.label)
            XCTAssertEqual(obj.value, .string("theStateHandle"))
            XCTAssertTrue(obj.required!)
            XCTAssertFalse(obj.visible!)
            XCTAssertFalse(obj.secret!)
            XCTAssertFalse(obj.mutable!)
        }
    }
    
    func testFormValueWithCompositeValue() throws {
        try decode(type: API.Response.FormValue.self, """
          {
            "label": "Email",
            "value": {
              "form": {
                "value": [
                  {
                    "name": "id",
                    "required": true,
                    "value": "aut2ihzk1gHl7ynhd1d6",
                    "mutable": false
                  },
                  {
                    "name": "methodType",
                    "required": false,
                    "value": "email",
                    "mutable": false
                  }
                ]
              }
            },
            "relatesTo": "$.authenticatorEnrollments.value[0]"
          }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.label, "Email")
            
            let form = obj.value?.toAnyObject() as? API.Response.CompositeForm
            XCTAssertNotNil(form)
            XCTAssertEqual(form?.form.value.count, 2)
            
            XCTAssertNotNil(obj.form)
            XCTAssertEqual(obj.form?.value.count ?? 0, 2)
        }
    }
    
    func testFormValueWithNestedForm() throws {
        try decode(type: API.Response.FormValue.self, """
        {
            "name": "credentials",
            "type": "object",
            "form": {
                "value": [{
                    "name": "passcode",
                    "label": "Password",
                    "secret": true
                }]
            },
            "required": true
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.name, "credentials")
            XCTAssertEqual(obj.type, "object")
            
            let form = obj.form?.value
            XCTAssertNotNil(form)
            XCTAssertEqual(form?.count, 1)
            XCTAssertEqual(form?.first?.name, "passcode")
        }
    }
    
    func testFormValueWithOptions() throws {
        try decode(type: API.Response.FormValue.self, """
          {
            "name": "authenticator",
            "type": "object",
            "options": [
              {
                "label": "Email"
              }
            ]
          }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.name, "authenticator")
            XCTAssertEqual(obj.type, "object")
            XCTAssertNotNil(obj.options)
            XCTAssertEqual(obj.options?.count, 1)
        }
    }
    
    func testFormValueWithOptionsContainingCompositeValue() throws {
        try decode(type: API.Response.FormValue.self, """
        {
           "name" : "authenticator",
           "options" : [
              {
                 "label" : "Email",
                 "relatesTo" : "$.authenticatorEnrollments.value[0]",
                 "value" : {
                    "form" : {
                       "value" : [
                          {
                             "mutable" : false,
                             "name" : "id",
                             "required" : true,
                             "value" : "aut3jya5v1oIgaLuV0g7"
                          },
                          {
                             "mutable" : false,
                             "name" : "methodType",
                             "required" : false,
                             "value" : "email"
                          }
                       ]
                    }
                 }
              }
           ],
           "type" : "object"
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.name, "authenticator")
            XCTAssertEqual(obj.type, "object")
            XCTAssertNotNil(obj.options)
            XCTAssertEqual(obj.options?.count, 1)
            
            let option = obj.options?[0]
            XCTAssertEqual(option?.label, "Email")
            XCTAssertEqual(option?.form?.value.count, 2)
            XCTAssertEqual(option?.form?.value[0].name, "id")
            XCTAssertEqual(option?.form?.value[1].name, "methodType")
            
            let publicObj = IDXClient.Remediation.Form.Field(client: clientMock, v1: obj)
            XCTAssertNotNil(publicObj)
            XCTAssertEqual(publicObj.name, "authenticator")
            XCTAssertEqual(publicObj.type, "object")
            XCTAssertNotNil(publicObj.options)
            XCTAssertEqual(publicObj.options?.count, 1)
            
            let publicOption = publicObj.options?[0]
            XCTAssertNotNil(publicOption)
            if let publicOption = publicOption {
                XCTAssertEqual(publicOption.label, "Email")
                XCTAssertEqual(publicOption.form?.count, 0)
                XCTAssertEqual(publicOption.form?.allFields.count, 2 )
                XCTAssertEqual(publicOption.form?.allFields[0].name, "id")
                XCTAssertEqual(publicOption.form?.allFields[1].name, "methodType")
                XCTAssertTrue(publicOption.isVisible)

                if let idValue = publicOption.form?.allFields[0] {
                    XCTAssertFalse(idValue.isVisible)
                }
            }
        }
    }
    
    func testFormValueWithMessages() throws {
        try decode(type: API.Response.FormValue.self, """
        {
           "label" : "Answer",
           "messages" : {
              "type" : "array",
              "value" : [
                 {
                    "class" : "ERROR",
                    "i18n" : {
                       "key" : "authfactor.challenge.question_factor.answer_invalid"
                    },
                    "message" : "Your answer doesn't match our records. Please try again."
                 }
              ]
           },
           "name" : "answer",
           "required" : true
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.name, "answer")
            XCTAssertNotNil(obj.messages)
            XCTAssertEqual(obj.messages?.type, "array")
            XCTAssertEqual(obj.messages?.value.count, 1)
            XCTAssertEqual(obj.messages?.value[0].type, "ERROR")
            XCTAssertEqual(obj.messages?.value[0].i18n?.key, "authfactor.challenge.question_factor.answer_invalid")
            XCTAssertEqual(obj.messages?.value[0].message, "Your answer doesn't match our records. Please try again.")
            
            let publicObj = IDXClient.Remediation.Form.Field(client: clientMock, v1: obj)
            XCTAssertNotNil(publicObj)
            XCTAssertNotNil(publicObj.messages)
            XCTAssertEqual(publicObj.messages.count, 1)
            XCTAssertEqual(publicObj.messages.first?.type, .error)
            XCTAssertEqual(publicObj.messages.first?.localizationKey, "authfactor.challenge.question_factor.answer_invalid")
            XCTAssertEqual(publicObj.messages.first?.message, "Your answer doesn't match our records. Please try again.")
        }
    }
    
    func testResponseWithMessages() throws {
        try decode(type: API.Response.self, """
        {
           "app" : {
              "type" : "object",
              "value" : {
                 "id" : "0ZczewGCFPlxNYYcLq5i",
                 "label" : "Test App",
                 "name" : "test_app"
              }
           },
           "cancel" : {
              "accepts" : "application/json; okta-version=1.0.0",
              "href" : "https://example.com/idp/idx/cancel",
              "method" : "POST",
              "name" : "cancel",
              "produces" : "application/ion+json; okta-version=1.0.0",
              "rel" : [
                 "create-form"
              ],
              "value" : [
                 {
                    "mutable" : false,
                    "name" : "stateHandle",
                    "required" : true,
                    "value" : "02n3QHV5ebMjjkDiCD53Iq439zXToRrX4QATZw4mEm",
                    "visible" : false
                 }
              ]
           },
           "expiresAt" : "2021-01-15T19:25:47.000Z",
           "intent" : "LOGIN",
           "messages" : {
              "type" : "array",
              "value" : [
                 {
                    "class" : "ERROR",
                    "i18n" : {
                       "key" : "errors.E0000004"
                    },
                    "message" : "Authentication failed"
                 }
              ]
           },
           "stateHandle" : "02n3QHV5ebMjjkDiCD53Iq439zXToRrX4QATZw4mEm",
           "version" : "1.0.0"
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertNotNil(obj.messages)
            XCTAssertEqual(obj.messages?.type, "array")
            XCTAssertEqual(obj.messages?.value.count, 1)
            XCTAssertEqual(obj.messages?.value[0].type, "ERROR")
            XCTAssertEqual(obj.messages?.value[0].i18n?.key, "errors.E0000004")
            XCTAssertEqual(obj.messages?.value[0].message, "Authentication failed")
            
            let publicObj = try IDXClient.Response(client: clientMock, v1: obj)
            XCTAssertNotNil(publicObj)
            XCTAssertNotNil(publicObj.messages)
            XCTAssertEqual(publicObj.messages.count, 1)
            XCTAssertEqual(publicObj.messages.first?.type, .error)
            XCTAssertEqual(publicObj.messages.first?.localizationKey, "errors.E0000004")
            XCTAssertEqual(publicObj.messages.first?.message, "Authentication failed")
        }
    }

    func testMessage() throws {
        try decode(type: API.Response.Message.self, """
         {
            "class" : "ERROR",
            "i18n" : {
               "key" : "errors.E0000004"
            },
            "message" : "Authentication failed"
         }
        """) { (obj) in
            XCTAssertEqual(obj.type, "ERROR")
            XCTAssertEqual(obj.i18n?.key, "errors.E0000004")
            XCTAssertEqual(obj.message, "Authentication failed")
            
            let publicObj = IDXClient.Message(client: clientMock, v1: obj)
            XCTAssertNotNil(publicObj)
            XCTAssertEqual(publicObj?.type, .error)
            XCTAssertEqual(publicObj?.localizationKey, "errors.E0000004")
            XCTAssertEqual(publicObj?.message, "Authentication failed")
        }
    }

    func testMessageWithEmptyLocKey() throws {
        try decode(type: API.Response.Message.self, """
         {
            "class" : "INFO",
            "message" : "Authentication failed"
         }
        """) { (obj) in
            XCTAssertEqual(obj.type, "INFO")
            XCTAssertNil(obj.i18n)
            XCTAssertEqual(obj.message, "Authentication failed")
            
            let publicObj = IDXClient.Message(client: clientMock, v1: obj)
            XCTAssertNotNil(publicObj)
            XCTAssertEqual(publicObj?.type, .info)
            XCTAssertNil(publicObj?.localizationKey)
            XCTAssertEqual(publicObj?.message, "Authentication failed")
        }
    }

    func testApplication() throws {
        try decode(type: API.Response.IonObject<API.Response.App>.self, """
           {
              "type" : "object",
              "value" : {
                 "id" : "0ZczewGCFPlxNYYcLq5i",
                 "label" : "Test App",
                 "name" : "client"
              }
           }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.type, "object")
            XCTAssertEqual(obj.value.id, "0ZczewGCFPlxNYYcLq5i")
            XCTAssertEqual(obj.value.label, "Test App")
            XCTAssertEqual(obj.value.name, "client")

            let publicObj = IDXClient.Application(v1: obj.value)
            XCTAssertNotNil(publicObj)
            XCTAssertEqual(publicObj?.id, "0ZczewGCFPlxNYYcLq5i")
            XCTAssertEqual(publicObj?.label, "Test App")
            XCTAssertEqual(publicObj?.name, "client")
        }
    }

    func testUser() throws {
        try decode(type: API.Response.IonObject<API.Response.User>.self, """
           {
              "type" : "object",
              "value" : {
                 "id" : "0ZczewGCFPlxNYYcLq5i",
              }
           }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj.type, "object")
            XCTAssertEqual(obj.value.id, "0ZczewGCFPlxNYYcLq5i")

            let publicObj = IDXClient.User(v1:  obj.value)
            XCTAssertNotNil(publicObj)
            XCTAssertEqual(publicObj?.id, "0ZczewGCFPlxNYYcLq5i")
        }
    }

    func testAuthenticatorWithSettings() throws {
        try decode(type: API.Response.IonObject<API.Response.Authenticator>.self, """
        {
          "type" : "object",
          "value" : {
             "displayName" : "Password",
             "id" : "lae8wj8nnjB3BrbcH0g6",
             "key" : "okta_password",
             "methods" : [
                {
                   "type" : "password"
                }
             ],
             "settings" : {
                "age" : {
                   "historyCount" : 4,
                   "minAgeMinutes" : 0
                },
                "complexity" : {
                   "excludeAttributes" : [],
                   "excludeUsername" : true,
                   "minLength" : 8,
                   "minLowerCase" : 1,
                   "minNumber" : 1,
                   "minSymbol" : 0,
                   "minUpperCase" : 1
                }
             },
             "type" : "password"
          }
        }
        """) { (obj) in
            XCTAssertEqual(obj.type, "object")
            XCTAssertEqual(obj.value.id, "lae8wj8nnjB3BrbcH0g6")

            let publicObj = try XCTUnwrap(IDXClient.Authenticator.makeAuthenticator(client: clientMock,
                                                                                    v1: [obj.value],
                                                                                    jsonPaths: [],
                                                                                    in: response) as? IDXClient.Authenticator.Password)
            XCTAssertEqual(publicObj.id, "lae8wj8nnjB3BrbcH0g6")
            
            let settings = try XCTUnwrap(publicObj.settings)

            XCTAssertEqual(settings.minLength, 8)
            XCTAssertTrue(settings.excludeUsername)
        }
    }

    func testAuthenticatorWithNullDisplayName() throws {
        try decode(type: API.Response.IonObject<API.Response.Authenticator>.self, """
        {
          "type" : "object",
          "value" : {
             "id" : "lae8wj8nnjB3BrbcH0g6",
             "key" : "okta_oth",
             "type" : "other"
          }
        }
        """) { (obj) in
            XCTAssertEqual(obj.type, "object")
            XCTAssertEqual(obj.value.id, "lae8wj8nnjB3BrbcH0g6")
            XCTAssertNil(obj.value.displayName)
            XCTAssertNil(obj.value.methods)

            let publicObj = try XCTUnwrap(IDXClient.Authenticator.makeAuthenticator(client: clientMock,
                                                                                    v1: [obj.value],
                                                                                    jsonPaths: [],
                                                                                    in: response))
            XCTAssertEqual(publicObj.id, "lae8wj8nnjB3BrbcH0g6")
            XCTAssertNil(publicObj.displayName)
            XCTAssertNil(publicObj.methods)
        }
    }

    func testIdpRemediation() throws {
        try decode(type: API.Response.Form.self, """
        {
            "href": "https://example.com/oauth2/avs2s4i2b4Cwi9PiG4k8/v1/authorize?client_id=O0a4ckjhvkcq2B88m54w9&request_uri=urn:okta:repLWTdpRjdldDJWaVNRMnVKY3pBV0pVeDB5IOI3SFJhVmE0UTlzTEwzdzowb2E0Y2V2TzZ3bGNxQzZtdDR3NA",
            "idp": {
                "id": "0oa4ccvO6wlbsC6mt4a4",
                "name": "Facebook IdP"
            },
            "method": "GET",
            "name": "redirect-idp",
            "type": "FACEBOOK"
        }
        """) { (obj) in
            XCTAssertNotNil(obj)
            XCTAssertNotNil(obj.href)
            XCTAssertEqual(obj.method, "GET")
            XCTAssertEqual(obj.name, "redirect-idp")
            XCTAssertEqual(obj.type, "FACEBOOK")

            let publicObj = IDXClient.Remediation.makeRemediation(client: clientMock, v1: obj) as? IDXClient.Remediation.SocialAuth
            XCTAssertNotNil(publicObj)
            XCTAssertEqual(publicObj?.redirectUrl, URL(string: "https://example.com/oauth2/avs2s4i2b4Cwi9PiG4k8/v1/authorize?client_id=O0a4ckjhvkcq2B88m54w9&request_uri=urn:okta:repLWTdpRjdldDJWaVNRMnVKY3pBV0pVeDB5IOI3SFJhVmE0UTlzTEwzdzowb2E0Y2V2TzZ3bGNxQzZtdDR3NA"))
            XCTAssertEqual(publicObj?.service, .facebook)
            XCTAssertEqual(publicObj?.idpName, "Facebook IdP")
        }
    }
    
    func testMultipleRelatedAuthenticators() throws {
        let obj = try decode(type: API.Response.self,
                             Bundle.testResource(fileName: "multiple-select-authenticator-authenticate"))
        let publicObj = try IDXClient.Response(client: clientMock, v1: obj)
        let remediation = try XCTUnwrap(publicObj.remediations[.selectAuthenticatorAuthenticate])
        let firstOption = try XCTUnwrap(remediation["authenticator"]?.options?[0])
        let secondOption = try XCTUnwrap(remediation["authenticator"]?.options?[1])
        
        let firstAuthenticator = try XCTUnwrap(firstOption.authenticator as? IDXClient.Authenticator.Email)
        let secondAuthenticator = try XCTUnwrap(secondOption.authenticator as? IDXClient.Authenticator.Email)
        XCTAssertNotEqual(firstAuthenticator, secondAuthenticator)
        XCTAssertEqual(firstAuthenticator.profile?["email"], "t***l@mailinator.com")
        XCTAssertEqual(secondAuthenticator.profile?["email"], "e***t@okta.com")
    }
}
