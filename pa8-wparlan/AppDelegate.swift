//
//  AppDelegate.swift
//  pa8-wparlan
//  This file holds AppDelegate and its implemenation *UNMODIFIED FOR THIS PROJECT*
//  CPSC 315-01, Fall 2020
//  Programming Assignment #8
//  No sources to site
//  Greeley worked on cocoaPods and main.storyboard and debugging
//  William worked on APIs and PlaceTableViewController and PlaceDetailViewController
//
//  Created by Parlan, William C and Lindberg, Greeley B on 12/11/20.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

