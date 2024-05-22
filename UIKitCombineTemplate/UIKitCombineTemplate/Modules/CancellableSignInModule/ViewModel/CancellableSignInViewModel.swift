//
//  CancellableSignInViewModel.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 22.05.24.
//

import UIKit
import Combine

/// Для бизнес логики экрана регистрации
final class CancellableSignInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var emailValidation = ""
    @Published var passwordValidation = ""
    @Published var validationStatus = ""

    var cancellable: AnyCancellable?

    var isSignInButtonEnabled: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    init() {
        cancellable = $email
            .map { [unowned self] value -> String in
                validationStatus = "Запрос на вход"
                return value
            }
            .delay(for: 5, scheduler: DispatchQueue.main)
            .sink { [unowned self] value in
                self.validationStatus = "Успешный вход"
            }
        
    }
    
    func cuncel() {
        validationStatus = "Операция отменена"
        cancellable?.cancel()
        cancellable = nil
    }
}
