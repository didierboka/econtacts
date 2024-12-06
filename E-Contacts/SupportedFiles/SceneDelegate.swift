//
//  SceneDelegate.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Config Window
        let window = UIWindow(windowScene: windowScene)
        let contactsViewController = ContactViewController()
        let navigationController = UINavigationController(rootViewController: contactsViewController)
        
        // Config view
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    
    // Methods for app life cycle
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    
    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    
    func sceneDidEnterBackground(_ scene: UIScene) {

    }
    

}

