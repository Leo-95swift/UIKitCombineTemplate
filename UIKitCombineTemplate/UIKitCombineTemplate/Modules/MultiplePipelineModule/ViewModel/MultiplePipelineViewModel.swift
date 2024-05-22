//
//  MultiplePipelineViewModel.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 22.05.24.
//

import UIKit
import Combine

class MultiplePipelineViewModel: ObservableObject {
    @Published var addedProducts: [Product] = []
    @Published var check: [Product] = []
    @Published var totalSum = 0

    var products: [Product] = [
        .init(name: "Яблоки 1 кг.", price: 120),
        .init(name: "Кефир 1 л.", price: 80),
        .init(name: "Овсянка 500 г.", price: 95),
        .init(name: "Свиной карбонат 500 г.", price: 1400),
        .init(name: "Виноград 1 кг.", price: 300),
        .init(name: "Чёрный хлеб 1 буханка", price: 50),
        .init(name: "Масло оливковое 1 л.", price: 1200)
    ]
    
    private var basketCancellables: Set<AnyCancellable> = []

    var totalSum1: Int {
        check.reduce(0) { $0 + $1.price }
    }
    
    init() {
        $addedProducts
            .map { products in
                products.filter { $0.price <= 1000 }
            }
            .sink { [unowned self] products in
                check = products
            }
            .store(in: &basketCancellables)
        
        $check
            .dropFirst()
            .scan(100) { accumulatedSum, newProducts in
                accumulatedSum + newProducts.reduce(0) { $0 + $1.price }
            }
            .sink { sum in
                self.totalSum = sum
            }
            .store(in: &basketCancellables)
        
        $check
            .dropFirst()
            .combineLatest($addedProducts)
            .map { check, addedProducts -> Int in
                let filteredCheck = check.filter { product in
                    addedProducts.contains { $0.id == product.id }
                }
                return 100 + filteredCheck.reduce(0) { $0 + $1.price }
            }
            .sink { [unowned self] sum in
                self.totalSum = sum
            }
            .store(in: &basketCancellables)
    }
    
    func clearBasket() {
        basketCancellables.removeAll()
        check.removeAll()
        addedProducts.removeAll()
        totalSum = 0
    }
}

