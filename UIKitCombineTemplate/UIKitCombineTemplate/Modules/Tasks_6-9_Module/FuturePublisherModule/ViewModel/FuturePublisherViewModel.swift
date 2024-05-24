//
//  FuturePublisherViewModel.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import SwiftUI
import Combine

class FuturePublisherViewModel: ObservableObject {
    @Published var textFieldText = ""
    @Published var textToShow = ""
    
    var cancellable: AnyCancellable?
    
    func checkPrimeNumber() -> AnyPublisher<Bool, PrimeCheckingError> {
        Deferred {
            Future { [unowned self] promise in
                guard let number = Int(self.textFieldText) else { promise(.failure(.castingFailed))
                    return
                }
                if isPrime(number) {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func check() {
        cancellable = checkPrimeNumber()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [unowned self] value in
                showDescription(isPrime: value)
            }
    }
    
    func isPrime(_ number: Int) -> Bool {
        // Числа меньше 2 не являются простыми
        if number < 2 {
            return false
        }
        // Проверяем делимость числа на все числа от 2 до number - 1
        for i in 2..<number {
            if number % i == 0 {
                return false
            }
        }
        return true
    }
    
    func showDescription(isPrime: Bool) {
        if isPrime {
            textToShow = "\(textFieldText) - простое число"
        } else {
            textToShow = "\(textFieldText) - не простое число"
        }
    }
    
}

