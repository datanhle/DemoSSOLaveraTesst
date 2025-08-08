//
//  ContextProvider.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import AuthenticationServices
import UIKit

final class ContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    private weak var anchorWindow: UIWindow?

    init(window: UIWindow?) {
        self.anchorWindow = window
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchorWindow ?? ASPresentationAnchor()
    }
}
