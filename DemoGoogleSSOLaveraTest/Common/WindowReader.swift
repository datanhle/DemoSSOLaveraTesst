//
//  Untitled.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import SwiftUI

struct WindowReader: UIViewRepresentable {
    let onResolve: (UIWindow?) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            onResolve(view.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
