//
//  NetworkMonitor.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation
import Network


class NetworkMonitorService {
    
    
    static let shared = NetworkMonitorService()
    private let monitor = NWPathMonitor()
    private(set) var isConnected = false
    var onConnectionRestored: (() -> Void)?
    
    
    private init() {
        setupMonitor()
    }
    
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? false
                self?.isConnected = path.status == .satisfied
                
                // Notifier si la connexion est rétablie
                if !wasConnected && self?.isConnected == true {
                    self?.onConnectionRestored?()
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitorService")
        monitor.start(queue: queue)
    }
}
