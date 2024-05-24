//
//  FailPublisherViewController.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import UIKit
import Combine

class FailPublisherViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let textFieldPlaceholder = "Введите число"
        static let addButtonTitle =  "Добавить"
        static let resetButtonTitle =  "Очистить список"
    }
    
    // MARK: - UI Elements
    
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let errorLabel = UILabel()
    
    // MARK: - ViewModel
    
    private let viewModel = FailPublisherViewModel()
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
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20)
        ])
        
        addButton.setTitle(Constants.addButtonTitle, for: .normal)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        resetButton.setTitle(Constants.resetButtonTitle, for: .normal)
        view.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20)
        ])
        
        errorLabel.textColor = .red
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        textField.textPublisher
            .assign(to: \.textFieldInput.value, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [unowned self] error in
                self.errorLabel.text = error?.rawValue
            }
            .store(in: &cancellables)
        
        addButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.addToList()
            }
            .store(in: &cancellables)
        
        resetButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.clearList()
            }
            .store(in: &cancellables)
        
        viewModel.$dataToView
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource

extension FailPublisherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataToView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.dataToView[indexPath.row]
        return cell
    }
}

