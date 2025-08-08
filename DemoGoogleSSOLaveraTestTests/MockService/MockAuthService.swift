//
//  Auth.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation
@testable import DemoGoogleSSOLaveraTest

final class MockAuthService: AuthServiceProtocol {
    
    var mockTokenResult: Result<TokenModel, Error>?
    var mockUserResult: Result<UserModel, Error>?
    var mockVoidResult: Result<Void, Error>?

    func buildAuthURL() -> URL {
        return URL(string: "https://mock-auth.com")!
    }

    func exchangeCodeForToken(code: String, completion: @escaping (Result<TokenModel, Error>) -> Void) {
        if let result = mockTokenResult {
            completion(result)
        }
    }

    func fetchUserInfo(accessToken: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        if let result = mockUserResult {
            completion(result)
        }
    }

    func refreshAccessToken(refreshToken: String, completion: @escaping (Result<TokenModel, Error>) -> Void) {
        if let result = mockTokenResult {
            completion(result)
        }
    }

    func revokeToken(_ token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = mockVoidResult {
            completion(result)
        }
    }
}


final class MockTokenStorage: TokenStorage {
    var storedToken: TokenModel?
    var saveCalled = false
    var loadCalled = false
    var deleteCalled = false
    var clearAllCalled = false

    func saveToken(_ token: TokenModel) -> Bool {
        saveCalled = true
        storedToken = token
        return true
    }

    func loadToken() -> TokenModel? {
        loadCalled = true
        return storedToken
    }

    func deleteToken() -> Bool {
        deleteCalled = true
        storedToken = nil
        return true
    }

    func clearAll() -> Bool {
        clearAllCalled = true
        storedToken = nil
        return true
    }
}

enum MockError: Error {
    case unknown
    case tokenError
}

extension TokenModel {
    static func mock(expiresIn: Int = 3600) -> TokenModel {
        return TokenModel(accessToken: "accessToken", expiresIn: 1000, refreshToken: "refreshToken", idToken: "idToken", tokenType: "tokenType", scope: "scope", issuedAt: Date())
    }
}

extension UserModel {
    static func mock(
        name: String = "Mock User",
        email: String = "mockuser@example.com",
        picture: String = "https://example.com/avatar.png"
    ) -> UserModel {
        return UserModel(name: name, email: email, picture: picture)
    }
}

