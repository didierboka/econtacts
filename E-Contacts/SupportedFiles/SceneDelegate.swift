//
//  SceneDelegate.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    
    // La propriété window est optionnelle car elle sera initialisée lors de la création de la scène
    var window: UIWindow?
    
    // Cette méthode est appelée lorsque l'application crée une nouvelle scène
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configuration de la fenêtre
        let window = UIWindow(windowScene: windowScene)
        let contactsViewController = ContactViewController()
        let navigationController = UINavigationController(rootViewController: contactsViewController)
        
        // Configuration de l'apparence
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    
    // Méthodes du cycle de vie de la scène
    func sceneDidDisconnect(_ scene: UIScene) {
        // Appelée lorsque la scène est déconnectée (en arrière-plan ou fermée)
    }

    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Appelée lorsque la scène devient active (premier plan)
    }

    
    func sceneWillResignActive(_ scene: UIScene) {
        // Appelée lorsque la scène va devenir inactive
    }

    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Appelée lorsque la scène va passer au premier plan
    }

    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Appelée lorsque la scène passe en arrière-plan
    }
    

}

