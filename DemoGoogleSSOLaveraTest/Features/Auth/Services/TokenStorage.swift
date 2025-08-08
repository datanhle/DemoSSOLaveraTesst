//
//  KeyChainServices.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation

protocol TokenStorage {
    func saveToken(_ token: TokenModel) -> Bool
    func loadToken() -> TokenModel?
    func deleteToken() -> Bool
    func clearAll() -> Bool
}

final class TokenStorageService: TokenStorage {
    private let keychain: KeychainStorable
    private let tokenKey = "oauth_token"

    init(keychain: KeychainStorable = KeychainServiceImpl()) {
        self.keychain = keychain
    }

    func saveToken(_ token: TokenModel) -> Bool {
        do {
            let data = try JSONEncoder().encode(token)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return false
            }
            return keychain.save(jsonString, for: tokenKey)
        } catch {
            print("❌ Token encode error: \(error)")
            return false
        }
    }

    func loadToken() -> TokenModel? {
        guard let jsonString = keychain.load(for: tokenKey),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(TokenModel.self, from: data)
        } catch {
            print("❌ Token decode error: \(error)")
            return nil
        }
    }

    func deleteToken() -> Bool {
        keychain.delete(key: tokenKey)
    }

    func clearAll() -> Bool {
        keychain.clearAll()
    }
}
