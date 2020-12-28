//
//  URLSessionMock.swift
//  okta-idx-ios-tests
//
//  Created by Mike Nachbaur on 2020-12-14.
//

import Foundation
@testable import OktaIdx

class URLSessionMock: URLSessionProtocol {
    struct Call {
        let data: Data?
        let response: HTTPURLResponse?
        let error: Error?
    }
    
    private var calls: [String: Call] = [:]
    func expect(_ url: String, call: Call) {
        calls[url] = call
    }
    
    func expect(_ url: String,
                data: Data?,
                statusCode: Int = 200,
                contentType: String = "application/x-www-form-urlencoded",
                error: Error? = nil)
    {
        let response = HTTPURLResponse(url: URL(string: url)!,
                                       statusCode: statusCode,
                                       httpVersion: "http/1.1",
                                       headerFields: ["Content-Type": contentType])
        
        expect(url, call: Call(data: data,
                               response: response,
                               error: error))
    }

    func expect(_ url: String,
                fileName: String,
                statusCode: Int = 200,
                contentType: String = "application/x-www-form-urlencoded",
                error: Error? = nil) throws
    {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: fileName, withExtension: "json") else {
            return
        }
        
        let data = try Data(contentsOf: path)
        
        expect(url,
               data: data,
               statusCode: statusCode,
               contentType: contentType,
               error: error)
    }

    func call(for url: String) -> Call? {
        return calls.removeValue(forKey: url)
    }
    
    func dataTaskWithRequest(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        let response = call(for: request.url!.absoluteString)
        return URLSessionDataTaskMock(data: response?.data,
                                      response: response?.response,
                                      error: response?.error,
                                      completionHandler: completionHandler)
    }
}

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    let completionHandler: (Data?, HTTPURLResponse?, Error?) -> Void
    let data: Data?
    let response: HTTPURLResponse?
    let error: Error?
    
    init(data: Data?,
         response: HTTPURLResponse?,
         error: Error?,
         completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        self.completionHandler = completionHandler
        self.data = data
        self.response = response
        self.error = error
    }
    
    func resume() {
        self.completionHandler(data, response, error)
    }
}
