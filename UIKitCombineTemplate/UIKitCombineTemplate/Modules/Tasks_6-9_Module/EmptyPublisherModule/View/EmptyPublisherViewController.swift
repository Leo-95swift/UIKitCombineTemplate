//
//  EmptyPublisherViewController.swift
//  UIKitCombineTemplate
//
//  Created by Levon Shaxbazyan on 24.05.24.
//

import UIKit
import Combine

class EmptyPublisherViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let textFieldPlaceholder = "Введите строку"
        static let addButtonTitle =  "Добавить"
        static let resetButtonTitle =  "Очистить список"
    }
    
    // MARK: - UI Elements
    
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    // MARK: - ViewModel
    
    private let viewModel = EmptyPublisherViewModel()
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
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
        
        addButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.valueToAdd.value = self.textField.text ?? ""
            }
            .store(in: &cancellables)
        
        resetButton.tapPublisher
            .sink { [unowned self] in
                self.viewModel.clearList()
            }
            .store(in: &cancellables)
        
        viewModel.dataToView
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource

extension EmptyPublisherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataToView.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.dataToView.value[indexPath.row]
        return cell
    }
}

// MARK: - Combine Extensions

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}

extension UIControl {
    var tapPublisher: AnyPublisher<Void, Never> {
        Publishers.ControlEvent(control: self, events: .touchUpInside)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension Publishers {
    struct ControlEvent<Control: UIControl>: Publisher {
        typealias Output = Control
        typealias Failure = Never
        
        let control: Control
        let controlEvents: UIControl.Event
        
        init(control: Control, events: UIControl.Event) {
            self.control = control
            self.controlEvents = events
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber, control: control, event: controlEvents)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.ControlEvent {
    final class Subscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Control, S.Failure == Never {

        
        private var subscriber: S?
        weak private var control: Control?
        
        init(subscriber: S, control: Control, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(eventOccured), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            subscriber = nil
        }
        
        @objc private func eventOccured() {
            _ = subscriber?.receive(control!)
        }
    }
}

