//
//  AppDelegate.swift
//  SOP
//
//  Created by Shivam Saini on 04/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Thread.sleep(forTimeInterval: 4.0)
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        IQKeyboardManager.shared.enable = true
        
        if let _ = UserDefaults.standard.object(forKey: "kUserId") {
            let homeScreenNavigationVC = UINavigationController()
            let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            homeScreenNavigationVC.viewControllers = [homeVC]
            if #available(iOS 11.0, *) {
                homeScreenNavigationVC.navigationBar.prefersLargeTitles = true
                homeScreenNavigationVC.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            }
            homeScreenNavigationVC.navigationBar.barTintColor = #colorLiteral(red: 0.222776711, green: 0.5253188014, blue: 0.6992447376, alpha: 1)
            homeScreenNavigationVC.navigationBar.backgroundColor = #colorLiteral(red: 0.222776711, green: 0.5253188014, blue: 0.6992447376, alpha: 1)
            self.window?.rootViewController = homeScreenNavigationVC
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

