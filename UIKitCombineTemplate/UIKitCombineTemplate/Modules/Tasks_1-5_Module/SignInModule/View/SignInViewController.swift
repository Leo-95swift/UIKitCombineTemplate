//
//  SignInView.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 22.05.24.
//

import UIKit
import Combine

class SignInViewController: UIViewController {

    // MARK: - Constants
    
    private enum Constants {
        static let bankLogo = "bankLogo"
    }
    
    // MARK: - UI Elements
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailValidationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordValidationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - ViewModel
    
    private let viewModel = SignInViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "signInBackground")
        
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField, emailValidationLabel,
            passwordTextField, passwordValidationLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(signInButton)
        
        let bankLogoImageView = UIImageView(image: UIImage(named: Constants.bankLogo))
        bankLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankLogoImageView)
        
        NSLayoutConstraint.activate([
            bankLogoImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 80
            ),
            bankLogoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            
            stackView.topAnchor.constraint(
                equalTo: bankLogoImageView.bottomAnchor,
                constant: 60
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            
            signInButton.topAnchor.constraint(
                equalTo: stackView.bottomAnchor,
                constant: 40
            ),
            signInButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
    
    private func setupBindings() {
           emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
           passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
           
        viewModel.$emailValidation
                  .receive(on: RunLoop.main)
                  .sink { [weak self] validation in
                      self?.emailValidationLabel.text = validation
                  }
                  .store(in: &cancellables)
              
              viewModel.$passwordValidation
                  .receive(on: RunLoop.main)
                  .sink { [weak self] validation in
                      self?.passwordValidationLabel.text = validation
                  }
                  .store(in: &cancellables)
              
              viewModel.$email
                  .combineLatest(viewModel.$password)
                  .map { [weak self] _ in
                      self?.viewModel.isSignInButtonEnabled ?? false
                  }
                  .receive(on: RunLoop.main)
                  .assign(to: \.isEnabled, on: signInButton)
                  .store(in: &cancellables)
              
              viewModel.$email
                  .sink { [weak self] email in
                      self?.emailTextField.text = email
                  }
                  .store(in: &cancellables)
              
              viewModel.$password
                  .sink { [weak self] password in
                      self?.passwordTextField.text = password
                  }
                  .store(in: &cancellables)
       }
       
       // MARK: - Actions
       
       @objc private func emailTextFieldDidChange() {
           viewModel.email = emailTextField.text ?? ""
       }
       
       @objc private func passwordTextFieldDidChange() {
           viewModel.password = passwordTextField.text ?? ""
       }
       
       @objc private func signInButtonTapped() {
           // Handle sign-in action
       }
    
}

