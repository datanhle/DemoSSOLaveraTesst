//
//  ContentView.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import SwiftUI
import AuthenticationServices
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var window: UIWindow?

    var body: some View {
         NavigationStack {
             VStack(spacing: 20) {
                 Text("Google SSO Demo")
                     .font(.title)

                 Button("Đăng nhập bằng Google") {
                     viewModel.login(withWindow: window)
                 }

                 NavigationLink(
                     destination: UserInfoView(),
                     isActive: $viewModel.isLoggedIn
                 ) {
                     EmptyView()
                 }
             }
             .background(WindowReader { self.window = $0 })
             .padding()
         }
     }
}

#Preview {
    ContentView()
}

