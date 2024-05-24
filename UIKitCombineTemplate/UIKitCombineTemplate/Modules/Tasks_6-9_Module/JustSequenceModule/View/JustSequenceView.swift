//
//  JustSequenceView.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import UIKit
import Combine

class JustSequenceViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let addFruitButtonTitle = "Добавить фрукт"
        static let removeFruitButtonTitle = "Удалить фрукт"
    }
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)
    
    // MARK: - ViewModel
    
    private let viewModel = JustSequenceViewModel()
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
        
        addButton.setTitle(Constants.addFruitButtonTitle, for: .normal)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        removeButton.setTitle(Constants.removeFruitButtonTitle, for: .normal)
        view.addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            removeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            removeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        viewModel.$dataToView
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        addButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.addFruit()
            }
            .store(in: &cancellables)
        
        removeButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.removeFruit()
            }
            .store(in: &cancellables)
        
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource

extension JustSequenceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataToView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.dataToView[indexPath.row]
        return cell
    }
}
