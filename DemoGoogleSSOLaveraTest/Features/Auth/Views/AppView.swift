//
//  AppView.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
                    if viewModel.isLoggedIn {
                        UserInfoView(viewModel: viewModel)
                    } else {
                        LoginView(viewModel: viewModel)
                    }

                    if viewModel.isLoading {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Loading...")
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                }
        .onAppear {
            viewModel.checkTokenOnLaunch()
        }
        .commonAlert(message: $viewModel.errorMessage)
    }
}
