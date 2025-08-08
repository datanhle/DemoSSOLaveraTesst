
# SwiftUI Google SSO App (OAuth2)

This project is a SwiftUI demo app implementing Google Sign-In using the OAuth2 Authorization Code Flow. It demonstrates a clean MVVM architecture with secure token storage, error handling, and reusability.

---

## 🚀 Features

- ✅ Google Sign-In using OAuth2 Authorization Code Flow  
- 🔒 Securely store access token in Keychain  
- 🔁 Automatically log in if a valid token exists  
- 🔄 Optional: Refresh token logic
- 👤 Fetch user profile data (name, email, avatar)  
- 🚪 Logout with token revocation and session clearing  
- ❗ Error handling with user feedback  
- 🧪 Unit tests with mock services for isolation and reliability  

---


## Structure
- Common
- Core/
 + Entity/
 + Network/
 + Storage/
- Feature/
 + View
 + ViewModel
 + Service
- Tests/
 + Mock/


## Pros
- Clean MVVM
- Secure token handling
- Testable design


## Build Instruction

Clone App from Git -> Open DemoGoogleSSOLaveraTest.xcodeproj -> Build App 
Cmd + U: Run Unit Test
