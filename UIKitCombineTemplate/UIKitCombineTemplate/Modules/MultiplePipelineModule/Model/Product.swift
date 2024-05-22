//
//  Product.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 22.05.24.
//

import Foundation

/// Описание товара
struct Product: Identifiable {
    // айдентифаер товара
    var id = UUID()
    // наименование товара
    var name: String
    // цена товара
    var price: Int
}
