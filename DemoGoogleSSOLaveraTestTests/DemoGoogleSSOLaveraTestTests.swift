//
//  DemoGoogleSSOLaveraTestTests.swift
//  DemoGoogleSSOLaveraTestTests
//
//  Created by DatLeAnh on 8/8/25.
//

import Testing
import XCTest
import DemoGoogleSSOLaveraTest

@testable import DemoGoogleSSOLaveraTest

import XCTest
@testable import DemoGoogleSSOLaveraTest

final class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    var mockAuthService: MockAuthService!
    var mockTokenStorage: MockTokenStorage!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockTokenStorage = MockTokenStorage()
        viewModel = AuthViewModel(authService: mockAuthService, tokenStorage: mockTokenStorage)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        mockTokenStorage = nil
        super.tearDown()
    }
    
    func test_handleAuthCode_success_shouldSetIsLoggedInTrue() {
        // Given
        let mockTokenStorage = MockTokenStorage()
        let mockAuthService = MockAuthService()
        let viewModel = AuthViewModel(authService: mockAuthService, tokenStorage: mockTokenStorage)

        let mockToken = TokenModel.mock()
        mockAuthService.mockTokenResult = .success(mockToken)

        // When
        let expectation = XCTestExpectation(description: "Handle auth code success")
        viewModel.handleAuthCode("valid_code")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertTrue(viewModel.isLoggedIn)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
    
    func test_handleAuthCode_failure_shouldSetErrorMessage() {
        // Given
        let mockTokenStorage = MockTokenStorage()
        let mockAuthService = MockAuthService()
        let viewModel = AuthViewModel(authService: mockAuthService, tokenStorage: mockTokenStorage)

        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid code"])
        mockAuthService.mockTokenResult = .failure(error)

        // When
        let expectation = XCTestExpectation(description: "Handle auth code failure")
        viewModel.handleAuthCode("invalid_code")

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(viewModel.isLoggedIn)
            XCTAssertEqual(viewModel.errorMessage, "Failed to get token: Invalid code")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }


    
    func test_tryAutoLogin_withValidToken_shouldCallFetchUserInfo() {
        // Given
        let mockTokenStorage = MockTokenStorage()
        let mockAuthService = MockAuthService()
        let viewModel = AuthViewModel(authService: mockAuthService, tokenStorage: mockTokenStorage)

        mockTokenStorage.storedToken = TokenModel.mock()
        mockAuthService.mockUserResult = .success(UserModel.mock())

        // When
        let expectation = XCTestExpectation(description: "Fetch user info on auto login")
        viewModel.tryAutoLogin()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.user?.name, UserModel.mock().name)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
    
    func test_tryAutoLogin_withValidToken_fetchUserFails_shouldSetErrorMessage() {
        // Given
        let mockTokenStorage = MockTokenStorage()
        let mockAuthService = MockAuthService()
        let viewModel = AuthViewModel(authService: mockAuthService, tokenStorage: mockTokenStorage)

        mockTokenStorage.storedToken = TokenModel.mock()
        
        let error = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        mockAuthService.mockUserResult = .failure(error)

        // When
        let expectation = XCTestExpectation(description: "Fetch user failure handled")
        viewModel.tryAutoLogin()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(viewModel.user)
            XCTAssertEqual(viewModel.errorMessage, "Failed to fetch user: Unauthorized")
            XCTAssertFalse(viewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

}
