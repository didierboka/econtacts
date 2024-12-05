//
//  ContactViewController.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation
import UIKit


class ContactViewController: UIViewController {
    
    
    // MARK: - Properties
    private let viewModel = ContactViewModels()
    
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        tableView.rowHeight = 70
        return tableView
    }()
    
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemBlue
        return refreshControl
    }()
    
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadContacts()
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation
        title = "Contacts"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // Configure tableView
        tableView.register(ContactItemView.self, forCellReuseIdentifier: ContactItemView.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshContacts), for: .valueChanged)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func setupBindings() {
        viewModel.onContactsFetched = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
        
        viewModel.onError = { [weak self] error in
            self?.refreshControl.endRefreshing()
            let alert = UIAlertController(title: "Erreur",
                                        message: error.localizedDescription,
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onLoading = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
    }
    
    
    // MARK: - Actions
    private func loadContacts() {
        viewModel.fetchContacts()
    }
    
    @objc private func refreshContacts() {
        viewModel.refreshContacts()
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactItemView.identifier, for: indexPath) as? ContactItemView else {
            return UITableViewCell()
        }
        
        let contact = viewModel.contacts[indexPath.row]
        cell.configure(with: contact)
        return cell
    }
}
