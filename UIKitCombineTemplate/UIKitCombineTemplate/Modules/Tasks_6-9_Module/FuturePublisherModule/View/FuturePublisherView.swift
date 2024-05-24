//
//  FuturePublisherView.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import UIKit
import Combine

class FuturePublisherViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let textFieldPlaceholder = "Введите число"
        static let checkButtonText = "Проверить простоту числа"
    }
    
    // MARK: - UI Elements
    
    private let textField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    
    // MARK: - ViewModel
    
    private let viewModel = FuturePublisherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        textField.placeholder = Constants.textFieldPlaceholder
        textField.borderStyle = .roundedRect
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        checkButton.setTitle(Constants.checkButtonText, for: .normal)
        view.addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        resultLabel.textColor = .green
        resultLabel.textAlignment = .center
        view.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        textField.textPublisher
            .assign(to: \.textFieldText, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$textToShow
            .receive(on: RunLoop.main)
        
        checkButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.check()
            }
            .store(in: &cancellables)
    }
}
