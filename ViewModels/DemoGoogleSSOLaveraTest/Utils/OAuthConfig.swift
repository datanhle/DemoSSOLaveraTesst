//
//  OAuthConfig.swift
//  GoogleSSOTestLavera
//
//  Created by DatLeAnh on 8/8/25.
//

struct OAuthConfig {
    static let clientID = "YOUR_CLIENT_ID"
    static let clientSecret = "YOUR_CLIENT_SECRET"
    static let redirectURI = "com.yourapp:/oauth2redirect"
    static let authURL = "https://accounts.google.com/o/oauth2/v2/auth"
    static let tokenURL = "https://oauth2.googleapis.com/token"
    static let scope = "openid email profile"
}
