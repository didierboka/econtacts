//
//  ContactItemView.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation
import UIKit


class ContactItemView: UITableViewCell {
    
    
    // MARK: - Properties
    static let identifier = "ContactItemView"
    
    
    // MARK: - UI Elements
    private let contactImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(contactImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contactImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contactImageView.widthAnchor.constraint(equalToConstant: 50),
            contactImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    
    // MARK: - Configuration
    func configure(with contact: ContactModel) {
        nameLabel.text = contact.name.fullName
        emailLabel.text = contact.email
        
        // Load image asynchronously
        if let url = URL(string: contact.picture.medium) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.contactImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contactImageView.image = nil
    }
}
