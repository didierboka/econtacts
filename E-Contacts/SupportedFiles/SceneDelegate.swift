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
        // Nous nous assurons que la scène est bien une windowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Création d'une nouvelle fenêtre avec la windowScene
        let window = UIWindow(windowScene: windowScene)
        
        // Création de notre contrôleur de vue principal
        let contactsViewController = ContactViewController()
        
        // Création d'un NavigationController avec notre ContactsViewController comme racine
        let navigationController = UINavigationController(rootViewController: contactsViewController)
        
        // Configuration de l'apparence de la barre de navigation
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        // Définition du contrôleur de navigation comme contrôleur racine de la fenêtre
        window.rootViewController = navigationController
        
        // Rendre la fenêtre visible
        window.makeKeyAndVisible()
        
        // Assignation de la fenêtre à notre propriété window
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

