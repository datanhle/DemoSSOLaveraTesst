//
//  AuthViewModels.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation
import Combine
import AuthenticationServices

final class AuthViewModel: ObservableObject {
    // MARK: - Published properties (UI binding)
    @Published var user: UserModel?
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private let tokenStorage: TokenStorage
    private var authSession: ASWebAuthenticationSession?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(authService: AuthServiceProtocol = AuthService(),
         tokenStorage: TokenStorage = TokenStorageService()) {
        self.authService = authService
        self.tokenStorage = tokenStorage
    }

    // MARK: - Auth Flow

    /// Start SSO flow by returning URL for WebAuthenticationSession
    func getAuthURL() -> URL {
        return authService.buildAuthURL()
    }

    /// Handle redirect with code → exchange for token → fetch user
    func handleAuthCode(_ code: String) {
        isLoading = true
        errorMessage = nil
        authService.exchangeCodeForToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                  switch result {
                  case .success(let token):
                      let saved = self?.tokenStorage.saveToken(token) ?? false
                                   if saved {
                                       DispatchQueue.main.async {
                                           self?.isLoggedIn = true
                                       }
                                   }
                  case .failure(let error):
                      self?.isLoading = false
                      self?.errorMessage = "Failed to get token: \(error.localizedDescription)"
                  }
              }
        }
    }

    /// Fetch user info after login or if token available
    func fetchUserInfo(accessToken: String? = nil) {
        let token = accessToken ?? tokenStorage.loadToken()?.accessToken

        guard let token else {
            self.errorMessage = "No access token found."
            self.isLoading = false
            return
        }

        authService.fetchUserInfo(accessToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch user: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Logout - revoke token, clear token & user
    func logout() {
        isLoading = true

        guard let token = tokenStorage.loadToken()?.accessToken else {
            clearSession()
            isLoading = false
            return
        }

        authService.revokeToken(token) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.clearSession()
                self.isLoading = false

                if case .failure(let error) = result {
                    self.errorMessage = "Logout failed: \(error.localizedDescription)"
                }
            }
        }
    }


    private func clearSession() {
        tokenStorage.clearAll()
        isLoggedIn = false
        user = nil
    }

    /// Auto login if token exists
    func tryAutoLogin() {
        if tokenStorage.loadToken()?.accessToken != nil {
            fetchUserInfo()
        }
    }
    
    func login(withWindow window: UIWindow?) {
         let url = getAuthURL()

         let callbackScheme = "com.googleusercontent.apps.167425563585-ud23pfdl0js8chfqmvske6j7jgg7jtts"
         let contextProvider = ContextProvider(window: window)

         authSession = ASWebAuthenticationSession(
             url: url,
             callbackURLScheme: callbackScheme
         ) { callbackURL, error in
             DispatchQueue.main.async {
                  if let error = error {
                      if let authError = error as? ASWebAuthenticationSessionError {
                                    switch authError.code {
                                    case .canceledLogin:
                                        self.errorMessage = "Login was cancelled by user."
                                    case .presentationContextNotProvided:
                                        self.errorMessage = "Login failed: Presentation context not provided."
                                    case .presentationContextInvalid:
                                        self.errorMessage = "Login failed: Presentation context invalid."
                                    @unknown default:
                                        self.errorMessage = "Login failed with unknown error: \(authError.localizedDescription)"
                                    }
                                } else {
                                    // ✅ Fallback for other error types
                                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                                }
                  } else if let callback = callbackURL,
                            let components = URLComponents(url: callback, resolvingAgainstBaseURL: false),
                            let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                      self.handleAuthCode(code)
                  } else {
                      self.errorMessage = "Authorization code not found."
                  }
              }
         }

         authSession?.presentationContextProvider = contextProvider
         authSession?.prefersEphemeralWebBrowserSession = true
         authSession?.start()
     }
    
    func checkTokenOnLaunch() {
        guard let token = tokenStorage.loadToken() else {
            self.isLoggedIn = false
            return
        }

        if isTokenExpired(token) {
            refreshToken()
        } else {
            self.isLoggedIn = true
        }
    }
    
    private func isTokenExpired(_ token: TokenModel) -> Bool {
        guard let expiresIn = token.expiresIn else {
            return true
        }

        let expiryDate = token.issuedAt.addingTimeInterval(TimeInterval(expiresIn - 5))
        return Date() >= expiryDate
    }
    
    private func refreshToken() {
        guard let refreshToken = tokenStorage.loadToken()?.refreshToken else {
            self.isLoggedIn = false
            return
        }

        authService.refreshAccessToken(refreshToken: refreshToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newToken):
                    // Lưu token mới
                    let saved = self?.tokenStorage.saveToken(newToken) ?? false
                                 if saved {
                                     DispatchQueue.main.async {
                                         self?.isLoggedIn = true
                                     }
                                 }
                case .failure(let error):
                    print("❌ Refresh token failed: \(error.localizedDescription)")
                    self?.isLoggedIn = false
                    self?.tokenStorage.clearAll()
                }
            }
        }
    }
}

extension AuthViewModel {
    struct Constants {
          static let userInfoTitle = "User Info"
          static let signOut = "Sign Out"
          static let unknownUser = "Unknown"
      }
}
