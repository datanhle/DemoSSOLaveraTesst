//
//  OAuthConfig.swift
//  GoogleSSOTestLavera
//
//  Created by DatLeAnh on 8/8/25.
//

struct OAuthConfig {
    static let clientID = "167425563585-ud23pfdl0js8chfqmvske6j7jgg7jtts.apps.googleusercontent.com"
    static let redirectURI = "com.googleusercontent.apps.167425563585-ud23pfdl0js8chfqmvske6j7jgg7jtts:/oauthredirect"
    static let authURL = "https://accounts.google.com/o/oauth2/v2/auth"
    static let tokenURL = "https://oauth2.googleapis.com/token"
    static let scope = "openid email profile"
}
