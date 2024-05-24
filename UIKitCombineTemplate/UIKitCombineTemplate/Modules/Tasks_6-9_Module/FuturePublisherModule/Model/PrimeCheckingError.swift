//
//  PrimeCheckingError.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import Foundation

public enum PrimeCheckingError: String, Error, Identifiable {
    public var id: String { rawValue }
    
    case castingFailed = "Couldn't cast String to Int"
}
