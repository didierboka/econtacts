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
    private let searchController = UISearchController(searchResultsController: nil)
    
    
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
        title = "E-Contacts"
        view.backgroundColor = .systemBackground
        
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Recherche"
        navigationItem.searchController = searchController
        // Important: ces deux lignes sont nécessaires
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // Configure tableView
        tableView.register(ContactItemView.self, forCellReuseIdentifier: ContactItemView.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshContacts), for: .valueChanged)
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = addButton
        
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
    
    
    @objc private func addButtonTapped() {
        showToast(message: "Bientôt disponible")
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
        viewModel.loadInitialContacts()
    }
    
    @objc private func refreshContacts() {
        viewModel.refreshContacts()
    }
    
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Rechercher un contact"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
    func showToast(message: String) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 16
        toastContainer.clipsToBounds = true
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -8),
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }

}


// MARK: - UITableViewDataSource
extension ContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredContacts.count // Utiliser filteredContacts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactItemView.identifier, for: indexPath) as? ContactItemView else {
            return UITableViewCell()
        }
        
        let contact = viewModel.filteredContacts[indexPath.row] // Utiliser filteredContacts
        cell.configure(with: contact)
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ContactViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.bounds.size.height
        
        if position > contentHeight - screenHeight - (screenHeight * 0.1) {
            // Ne charger plus que si on n'est pas en train de rechercher
            if searchController.searchBar.text?.isEmpty ?? true {
                viewModel.loadMoreIfNeeded(currentIndex: viewModel.contacts.count - 1)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = CGPoint(x: footerView.bounds.midX, y: footerView.bounds.midY)
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        footerView.isHidden = !viewModel.isLoading
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.isLoading ? 50 : 0
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = viewModel.filteredContacts[indexPath.row]
        let detailVC = ContactDetailViewController(contact: contact)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


extension ContactViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filterContacts(with: searchText)
    }
}

