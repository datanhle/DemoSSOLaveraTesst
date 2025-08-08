//
//  DemoGoogleSSOLaveraTestApp.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import SwiftUI

@main
struct DemoGoogleSSOLaveraTestApp: App {
    @StateObject private var viewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(viewModel)
        }
    }
}
