//
//  AppDelegate.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import UserNotifications

let DEBUG_MODE = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		//Initialize the firebase application
		FirebaseApp.configure()
		
		//Change the status bar color for the entire app
		UINavigationBar.appearance().barStyle = .black
		
		//Request authorization to receive notifications
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
			//Connect to APNS and get token (must be done on the main thread)
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		}
		
		//Handle app opening from a notification
		if let notification = launchOptions?[.remoteNotification] as? [String: Any], let aps = notification["aps"] as? [String: Any] {
			if let ladderId = aps["ladder_id"] as? Int {
				((self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? MainViewController)?.ladderIdToLaunch = ladderId
			}
		}
		
        return true
    }
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String) ?? false {
			return true
		}
		
		//Other URL handling goes here.
		return false
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		//Turn the token into a string
		let hexToken = deviceToken.map { String(format: "%02hhx", $0) }.joined()
		print("Device Token: \(hexToken)")
		
		//TODO: Send this to the server
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		//TODO
	}
}

