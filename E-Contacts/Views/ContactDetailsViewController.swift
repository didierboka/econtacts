//
//  ContactDetailsViewController.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 05/12/2024.
//

import Foundation
import UIKit


class ContactDetailViewController: UIViewController {
    
    

    // MARK: - Properties
        private let contact: ContactModel
        
        // MARK: - UI Elements
        private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
        
        private let contentView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 60  // Augmenté pour une plus grande image
            imageView.backgroundColor = .systemGray5
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 20  // Augmenté pour plus d'espacement
            stack.alignment = .center  // Centre les éléments horizontalement
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        // MARK: - Initialization
        init(contact: ContactModel) {
            self.contact = contact
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            configureWithContact()
        }
        
        // MARK: - Setup
        private func setupUI() {
            view.backgroundColor = .systemBackground
            
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            contentView.addSubview(profileImageView)
            contentView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
                profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 120),  // Plus grande image
                profileImageView.heightAnchor.constraint(equalToConstant: 120),
                
                stackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
            ])
        }
        
        private func configureWithContact() {
            title = contact.name.fullName
            
            // Load profile image
            if let url = URL(string: contact.picture.large) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.profileImageView.image = image
                        }
                    }
                }.resume()
            }
            
            // Add information sections
            addInfoSection(title: "Prénom", value: contact.name.first)
            addInfoSection(title: "Nom", value: contact.name.last)
            addInfoSection(title: "Adresse", value: formatAddress())
            addInfoSection(title: "Email", value: contact.email)
            addInfoSection(title: "Téléphone fixe", value: contact.phone)
            addInfoSection(title: "Téléphone mobile", value: contact.cell)
        }
        
        private func addInfoSection(title: String, value: String) {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
            titleLabel.textColor = .secondaryLabel
            titleLabel.textAlignment = .center  // Centré
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .systemFont(ofSize: 17)
            valueLabel.numberOfLines = 0
            valueLabel.textAlignment = .center  // Centré
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(titleLabel)
            container.addSubview(valueLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                
                valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            // Ajouter une ligne de séparation
            let separator = UIView()
            separator.backgroundColor = .systemGray5
            separator.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
                separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -40),
                separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            stackView.addArrangedSubview(container)
        }
        
        private func formatAddress() -> String {
            let location = contact.location
            return """
            \(location.street.number) \(location.street.name)
            \(location.postcode) \(location.city)
            \(location.state), \(location.country)
            """
        }
    
    
    
}
