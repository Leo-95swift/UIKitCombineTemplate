//
//  MultiplePipelineView.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 22.05.24.
//

import UIKit
import Combine

class MultiplePipelineViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let productTitle = "Товар"
        static let productPriceTitle = "Цена"
        static let fontName = "Verdana-bold"
        static let resetBasketText = "Очистить корзину"
    }
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    private let totalSumLabel = UILabel()
    private let resetButton = UIButton(type: .system)
    
    // MARK: - ViewModel
    
    private let viewModel = MultiplePipelineViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // Table View
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Total Sum Label
        totalSumLabel.font = UIFont.systemFont(ofSize: 18)
        totalSumLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalSumLabel)
        
        // Reset Button
        resetButton.setTitle(Constants.resetBasketText, for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: totalSumLabel.topAnchor, constant: -20),
            
            totalSumLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalSumLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalSumLabel.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -20),
            
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        viewModel.$totalSum
            .receive(on: RunLoop.main)
            .sink { [weak self] totalSum in
                self?.totalSumLabel.text = "Итоговая сумма: \(totalSum)"
            }
            .store(in: &cancellables)
        
        viewModel.$addedProducts
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func resetButtonTapped() {
        viewModel.clearBasket()
    }
}

// MARK: - TableView DataSource & Delegate

extension MultiplePipelineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.products.count
        case 1:
            return viewModel.check.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            let product = viewModel.products[indexPath.row]
            cell.textLabel?.text = product.name
            let stepper = UIStepper()
            stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = stepper
        case 1:
            let product = viewModel.check[indexPath.row]
            cell.textLabel?.text = "\(product.name) - \(product.price) руб."
            cell.accessoryView = nil
        default:
            break
        }
        
        return cell
    }
    
    @objc private func stepperValueChanged(_ sender: UIStepper) {
        guard let cell = sender.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let product = viewModel.products[indexPath.row]
        
        if sender.value > 0 {
            if viewModel.addedProducts.allSatisfy({ $0.id != product.id }) {
                viewModel.addedProducts.append(product)
            }
        } else {
            if let position = viewModel.addedProducts.firstIndex(where: { $0.id == product.id }) {
                viewModel.addedProducts.remove(at: position)
            }
        }
    }
}
