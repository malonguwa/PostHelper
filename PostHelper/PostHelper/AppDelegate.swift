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
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        SDKSettings.disableLoggingBehavior(SDKLoggingBehavior.uiControlErrors)
//        SDKSettings.disableLoggingBehavior(SDKLoggingBehavior.cacheErrors)
//        SDKSettings.disableLoggingBehavior(SDKLoggingBehavior.networkRequests)
//        SDKSettings.disableLoggingBehavior(SDKLoggingBehavior.developerErrors)
//        SDKSettings.disableLoggingBehavior(SDKLoggingBehavior.informational)
        

        Fabric.with([Twitter.self])
        
        let postSomethingIcon = UIApplicationShortcutIcon(templateImageName: "post2")
        let postSomethingItem = UIApplicationShortcutItem(type: "postSomething", localizedTitle: "Post Something", localizedSubtitle: nil, icon: postSomethingIcon, userInfo: nil)
        UIApplication.shared.shortcutItems = [postSomethingItem]
        
        
        return true

        
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        let appId = SDKSettings.appId
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId)") && url.host ==  "authorize" { // facebook
            return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }

        if Twitter.sharedInstance().application(app, open:url, options: options) {
            return true
        }

//        if SDKApplicationDelegate.shared.application(app, open: url, options:  options) {
//            return true
//        }
 
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

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type == "postSomething" {
            print("postSomething")
            let loginSB = UIStoryboard(name: "HALogin", bundle: nil)
            let loginVC = loginSB.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = loginVC
            
            let dict = ["segueID":"HA_loginToPost",
                        "loginVC":loginVC!] as [String : Any]
            
            perform(#selector(AppDelegate.perforSegue(dict:)), with: dict, afterDelay: 0.3)
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    internal func perforSegue(dict: Dictionary<String, Any>!) {
        let loginVC = dict["loginVC"] as! HALoginVC
        let identifier = dict["segueID"]
        loginVC.performSegue(withIdentifier: identifier as! String, sender: nil)

    }

}

