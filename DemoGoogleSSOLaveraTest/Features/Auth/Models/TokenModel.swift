//
//  TokenModel.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation

struct TokenModel: Codable {
    let accessToken: String
    let expiresIn: Int?
    let refreshToken: String?
    let idToken: String?
    let tokenType: String?
    let scope: String?
    let issuedAt: Date  
}
