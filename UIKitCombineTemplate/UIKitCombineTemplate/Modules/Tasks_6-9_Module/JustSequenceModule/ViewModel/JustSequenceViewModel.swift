//
//  JustSequenceViewModel.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import SwiftUI
import Combine

class JustSequenceViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    var currentFruitIndex = 0
    var additionalFruits = ["Fruit 4", "Fruit 5", "Fruit 6"]
    
    var cancellables: Set<AnyCancellable> = []
    
    func addFruit() {
        calculateWhatToAdd()
    }
    
    func removeFruit() {
        guard dataToView.count > 0 else { return }
        _ = dataToView.removeLast()
        if dataToView.count >= 3 {
            currentFruitIndex -= 1
        }
    }
    
    
    func calculateWhatToAdd() {
        switch dataToView.count {
        case 0:
            _ = Just("Apple (initial)")
                .sink { [unowned self] item in
                    dataToView.append(item)
                }
        case 1:
            _ = Just("Banana (initial)")
                .sink { [unowned self] item in
                    dataToView.append(item)
                }
        case 2:
           _ = Just("Orange (initial)")
                .sink { [unowned self] item in
                    dataToView.append(item)
                }
        default:
            guard currentFruitIndex < additionalFruits.count else { return }
            _ = additionalFruits[currentFruitIndex...currentFruitIndex].publisher
                .sink { [unowned self] item in
                    print(item)
                    dataToView.append(item)
                    currentFruitIndex += 1
                }
        }
    }
}

