//
//  HTTPMethod.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIRequestEncoding {
    case json
    case urlEncoded
}

struct APIRequest {
    let url: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: [String: Any]?
    let encoding: APIRequestEncoding
}
