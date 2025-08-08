//
//  KeyChainServices.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

protocol TokenStorage {
    func saveAccessToken(_ token: String) -> Bool
    func loadAccessToken() -> String?
    func deleteAccessToken() -> Bool

    func saveRefreshToken(_ token: String) -> Bool
    func loadRefreshToken() -> String?
    func deleteRefreshToken() -> Bool

    func clearAll() -> Bool
}

final class TokenStorageService: TokenStorage {
    private let keychain: KeychainStorable
    private let accessKey = "access_token"
    private let refreshKey = "refresh_token"

    init(keychain: KeychainStorable = KeychainServiceImpl()) {
        self.keychain = keychain
    }

    func saveAccessToken(_ token: String) -> Bool {
        keychain.save(token, for: accessKey)
    }

    func loadAccessToken() -> String? {
        keychain.load(for: accessKey)
    }

    func deleteAccessToken() -> Bool {
        keychain.delete(key: accessKey)
    }

    func saveRefreshToken(_ token: String) -> Bool {
        keychain.save(token, for: refreshKey)
    }

    func loadRefreshToken() -> String? {
        keychain.load(for: refreshKey)
    }

    func deleteRefreshToken() -> Bool {
        keychain.delete(key: refreshKey)
    }

    func clearAll() -> Bool {
        keychain.clearAll()
    }
}
