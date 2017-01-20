//
//  AppDelegate.swift
//  PostHelper
//
//  Created by LONG MA on 15/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookCore
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Fabric.with([Twitter.self])
        let result = SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        hasAccessToTwitter()
        hasAccessToFacebook()
        
        
        return result

        
    }
    
   public func hasAccessToTwitter() -> Bool {
        if Twitter.sharedInstance().sessionStore.session() == nil {
            print("Twitter session = nil")
            return false
        } else {
            print("Twitter session = \(Twitter.sharedInstance().sessionStore.session())")
            return true
        }
    }
    
   public func hasAccessToFacebook() -> Bool {

        if AccessToken.current == nil{
            print("Facebook AccessToken = nil")
            return false
        } else {
            print("Facebook AccessToken expirationDate = \(AccessToken.current?.expirationDate)")
            return true
        }
    }
    
    /**
     func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
     
     if Twitter.sharedInstance().application(app, openURL:url, options: options) {
        return true
     }
     
     let sourceApplication: String? = options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String
        return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: sourceApplication, annotation: nil)
     }
     */
    


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Twitter.sharedInstance().application(app, open:url, options: options) {
            return true
        }
        
        if SDKApplicationDelegate.shared.application(app, open: url, options:  options) {
            return true
        }
 
        return false
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

