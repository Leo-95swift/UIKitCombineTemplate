//
//  SignInViewModel.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 22.05.24.
//

import SwiftUI
import Combine

/// Для бизнес логики экрана регистрации
final class SignInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var emailValidation = ""
    @Published var passwordValidation = ""

    var isSignInButtonEnabled: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        $email
            .map { $0.isEmpty ? "❌" : "✅" }
            .assign(to: &$emailValidation)
        
        $password
            .map { $0.isEmpty ? "❌" : "✅" }
            .assign(to: &$passwordValidation)
    }
}
