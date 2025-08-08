//
//  CommonAlert.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import SwiftUI

struct CommonAlertModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content
            .alert(item: Binding(
                get: {
                    message.map { CommonAlertMessage(id: UUID(), message: $0) }
                },
                set: { _ in
                    message = nil
                }
            )) { alertItem in
                Alert(
                    title: Text("Error"),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

struct CommonAlertMessage: Identifiable {
    let id: UUID
    let message: String
}

extension View {
    func commonAlert(message: Binding<String?>) -> some View {
        self.modifier(CommonAlertModifier(message: message))
    }
}
