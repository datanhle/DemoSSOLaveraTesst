//
//  TokenResponse.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//
import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
    let expiresIn: Int?
    let refreshToken: String?
    let idToken: String?
    let tokenType: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case tokenType = "token_type"
        case scope
    }
    
    func toModel() -> TokenModel {
          return TokenModel(
              accessToken: accessToken,
              expiresIn: expiresIn,
              refreshToken: refreshToken,
              idToken: idToken,
              tokenType: tokenType,
              scope: scope,
              issuedAt: Date()
          )
      }
}
