//
//  UserView.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import SwiftUI

import SwiftUI

struct UserInfoView: View {
    @StateObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(AuthViewModel.Constants.userInfoTitle)
                .font(.title)
                .fontWeight(.semibold)

            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(.top, 20)

            if let user = viewModel.user {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                viewModel.logout()
            }) {
                Text(AuthViewModel.Constants.signOut)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchUserInfo()
        }
        .commonAlert(message: $viewModel.errorMessage)
    }
}
