//
//  AuthService.swift
//  GoogleSSOTestLavera
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation
import Combine

// MARK: - Protocol

protocol AuthServiceProtocol {
    func buildAuthURL() -> URL
    func exchangeCodeForToken(code: String, completion: @escaping (Result<TokenModel, Error>) -> Void)
    func fetchUserInfo(accessToken: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func refreshAccessToken(refreshToken: String, completion: @escaping (Result<TokenModel, Error>) -> Void)
    func revokeToken(_ token: String, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - Implementation

final class AuthService: AuthServiceProtocol {
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    // MARK: - Build Google Auth URL

    func buildAuthURL() -> URL {
        var components = URLComponents(string: OAuthConfig.authURL)!
        components.queryItems = [
            .init(name: "client_id", value: OAuthConfig.clientID),
            .init(name: "redirect_uri", value: OAuthConfig.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: OAuthConfig.scope),
        ]
        return components.url!
    }
    
    // MARK: - Refresh token when access token expried
    func refreshAccessToken(refreshToken: String, completion: @escaping (Result<TokenModel, Error>) -> Void) {
           let body: [String: String] = [
               "client_id": OAuthConfig.clientID,
               "refresh_token": refreshToken,
               "grant_type": "refresh_token"
           ]

        let request = APIRequest(
            url: OAuthConfig.tokenURL,
            method: .get,
            headers: nil,
            body: body,
            encoding: .urlEncoded
        )
        
        apiService.request(request) { (result: Result<TokenResponse, Error>) in
            switch result {
            case .success(let token):
                completion(.success(token.toModel()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
       }

    // MARK: - Exchange Authorization Code for Access Token

    func exchangeCodeForToken(code: String, completion: @escaping (Result<TokenModel, Error>) -> Void) {
        let body: [String: Any] = [
            "code": code,
            "client_id": OAuthConfig.clientID,
            "redirect_uri": OAuthConfig.redirectURI,
            "grant_type": "authorization_code"
        ]

        let request = APIRequest(
            url: OAuthConfig.tokenURL,
            method: .post,
            headers: nil,
            body: body,
            encoding: .urlEncoded
        )

        apiService.request(request) { (result: Result<TokenResponse, Error>) in
            switch result {
            case .success(let token):
                completion(.success(token.toModel()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch User Info

    func fetchUserInfo(accessToken: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let headers = ["Authorization": "Bearer \(accessToken)"]

        let request = APIRequest(
            url: "https://www.googleapis.com/oauth2/v3/userinfo",
            method: .get,
            headers: headers,
            body: nil,
            encoding: .json
        )

        apiService.request(request, completion: completion)
    }
    
    func revokeToken(_ token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body: [String: String] = [
            "token": token
        ]

        let request = APIRequest(
            url: "https://oauth2.googleapis.com/revoke",
            method: .post,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            body: body,
            encoding: .urlEncoded
        )

        apiService.requestRaw(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
