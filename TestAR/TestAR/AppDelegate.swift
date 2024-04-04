//
//  AppDelegate.swift
//  TestAR
//
//  Created by Din Vu Dinh on 04/04/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = UIColor.black
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        UnityEmbedded.setHostMainWindow(window)
        UnityEmbedded.setLaunchinOptions(launchOptions)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    

}
