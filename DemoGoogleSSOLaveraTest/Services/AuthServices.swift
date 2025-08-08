//
//  AuthService.swift
//  GoogleSSOTestLavera
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation
import AuthenticationServices

// MARK: - Protocol

protocol AuthServiceProtocol {
    func buildAuthURL() -> URL
    func exchangeCodeForToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
    func fetchUserInfo(accessToken: String, completion: @escaping (Result<UserModel, Error>) -> Void)
}

final class AuthService: AuthServiceProtocol {

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

    func exchangeCodeForToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: URL(string: OAuthConfig.tokenURL)!)
        request.httpMethod = "POST"
        let body = [
            "code": code,
            "client_id": OAuthConfig.clientID,
            "redirect_uri": OAuthConfig.redirectURI,
            "grant_type": "authorization_code"
        ]
        request.httpBody = body
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }

            do {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                if let token = json["access_token"] {
                    completion(.success(token))
                } else {
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchUserInfo(accessToken: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v3/userinfo")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }

            do {
                let user = try JSONDecoder().decode(UserModel.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
