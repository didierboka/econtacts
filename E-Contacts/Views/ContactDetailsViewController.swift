//
//  ContactDetailsViewController.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation
import UIKit


class ContactDetailViewController: UIViewController {
    
    


        private let contact: ContactModel
        

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
            imageView.layer.cornerRadius = 60
            imageView.backgroundColor = .systemGray5
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 20
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
    
        init(contact: ContactModel) {
            self.contact = contact
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            configureWithContact()
        }
        
    
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
                profileImageView.widthAnchor.constraint(equalToConstant: 120),
                profileImageView.heightAnchor.constraint(equalToConstant: 120),
                
                stackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
            ])
        }
        
        private func configureWithContact() {
            title = contact.name.fullName
            
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
                
                // for call number (clicable)
                let valueView: UIView
                if title == "Téléphone fixe" || title == "Téléphone mobile" {
                    let button = UIButton(type: .system)
                    button.setTitle(value, for: .normal)
                    button.titleLabel?.font = .systemFont(ofSize: 17)
                    button.titleLabel?.numberOfLines = 0
                    button.titleLabel?.textAlignment = .center
                    button.addTarget(self, action: #selector(phoneNumberTapped(_:)), for: .touchUpInside)
                    // Lock number info on identifier tag button
                    button.accessibilityIdentifier = value
                    valueView = button
                } else {
                    let label = UILabel()
                    label.text = value
                    label.font = .systemFont(ofSize: 17)
                    label.numberOfLines = 0
                    label.textAlignment = .center
                    valueView = label
                }
            
            
            valueView.translatesAutoresizingMaskIntoConstraints = false
               
           container.addSubview(titleLabel)
           container.addSubview(valueView)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                
                valueView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                valueView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                valueView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
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
    
    
    
    // Adding call logic ...
    @objc private func phoneNumberTapped(_ sender: UIButton) {
        // showToast(message: "Bientôt disponible"
        
        /*guard let phoneNumber = sender.accessibilityIdentifier else { return }
        
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        if let phoneURL = URL(string: "tel://\(cleanNumber)") {
            // Vérifier si le dispositif peut faire des appels
            if UIApplication.shared.canOpenURL(phoneURL) {
                // Créer une alerte de confirmation
                let alert = UIAlertController(
                    title: "Appeler le \(sender.titleLabel?.text ?? "numéro")?",
                    message: nil,
                    preferredStyle: .actionSheet
                )
                
                // Action d'appel
                alert.addAction(UIAlertAction(title: "Appeler", style: .default) { _ in
                    UIApplication.shared.open(phoneURL)
                })
                
                // Action d'annulation
                alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
                
                // Pour iPad
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = sender
                    popoverController.sourceRect = sender.bounds
                }
                
                present(alert, animated: true)
            }
        }*/
    }
    
}
