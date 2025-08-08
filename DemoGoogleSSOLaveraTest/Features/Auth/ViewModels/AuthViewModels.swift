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
                      print("✅ Got token: \(token)")
                      self?.tokenStorage.saveAccessToken(token)
                      self?.fetchUserInfo(accessToken: token)
                  case .failure(let error):
                      self?.isLoading = false
                      self?.errorMessage = "Failed to get token: \(error.localizedDescription)"
                  }
              }
        }
    }

    /// Fetch user info after login or if token available
    func fetchUserInfo(accessToken: String? = nil) {
        let token = accessToken ?? tokenStorage.loadAccessToken()

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

    /// Logout - clear token & user
    func logout() {
        let _ = tokenStorage.deleteAccessToken()
        user = nil
    }

    /// Auto login if token exists
    func tryAutoLogin() {
        if tokenStorage.loadAccessToken() != nil {
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
                      self.errorMessage = error.localizedDescription
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
}
