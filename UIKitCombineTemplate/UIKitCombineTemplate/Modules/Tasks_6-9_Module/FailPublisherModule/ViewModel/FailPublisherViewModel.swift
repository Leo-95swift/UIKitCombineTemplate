//
//  FailPublisherViewModel.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import UIKit
import Combine

class FailPublisherViewModel: ObservableObject {
    @Published var error: InvalidInput?
    @Published var dataToView: [String] = []
    
        var textFieldInput = CurrentValueSubject<String, Never>("")
        var valueToAdd = CurrentValueSubject<String, Never>("")
        var datas: [String?] = []
        var cancellables: Set<AnyCancellable> = []
        
    init() {
        valueToAdd
            .dropFirst()
                .sink { [unowned self] newValue in
                    datas.append(newValue)
                    dataToView.removeAll()
                    fetch()
                }
                .store(in: &cancellables)
        }
    
    func addToList() {
        _ = validate(value: textFieldInput.value)
            .sink { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                valueToAdd.value = value
            }
    }
    
    
    func validate(value: String) -> AnyPublisher<String, InvalidInput> {
        if isNonNumeric(input: value) {
            return Fail(error: InvalidInput.nonNumeric)
                .eraseToAnyPublisher()
        } else {
            error = nil
            return Just(value)
                .setFailureType(to: InvalidInput.self)
                .eraseToAnyPublisher()
        }
    }
    
    func isNonNumeric(input: String) -> Bool {
        if input.isEmpty || input == " " {
            return true
        }
        for char in input {
            if !char.isNumber {
                return true
            }
        }
        return false
    }
    
    func fetch() {
        _ = datas.publisher
            .flatMap { item -> AnyPublisher<String, Never> in
                if let item = item {
                    return Just(item)
                        .eraseToAnyPublisher()
                } else {
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
            }
            .sink { [unowned self] item in
                dataToView.append(item)
            }
    }
    
    func clearList() {
        datas.removeAll()
        dataToView.removeAll()
        error = nil
        textFieldInput.value = ""
    }
}

