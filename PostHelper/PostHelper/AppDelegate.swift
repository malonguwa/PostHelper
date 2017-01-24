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


public var hasAuthToTwitter : Bool?
public var hasAuthToFacebook : Bool?
public var platforms = [SocialPlatform]()
public enum SocialPlatform { // send squence
    case HATwitter
    case HAFacebook
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Twitter.self])
        
        print("facebook 1 didFinishLaunchingWithOptions\(AccessToken.current?.userId)\n")
        hasAuthToTwitter = HALoginVC.hasAccessToTwitter()
        hasAuthToFacebook = HALoginVC.hasAccessToFacebook()
        print("facebook 2 didFinishLaunchingWithOptions\(AccessToken.current?.userId)\n")

        
        if platforms.count != 0 {
            if hasAuthToTwitter == true && platforms[0] != .HATwitter {
                platforms.insert(.HATwitter, at: 0)
            } else if hasAuthToFacebook == true {
                var flag : Bool = false
                for platform in platforms.enumerated() {
                    if platform.element == .HAFacebook {
                        flag = true
                    }
                }
                if flag == false {
                    platforms.append(.HAFacebook)
                }
            }
        } else {
            if hasAuthToTwitter == true {
                platforms.append(.HATwitter)
            }
            if hasAuthToFacebook == true {
                platforms.append(.HAFacebook)
            }
        }
        
//        if hasAuthToTwitter! == true {
//            platforms.append(.HATwitter) // send squence: Twitter -> Facebook
//        }
//        
//        if hasAuthToFacebook! == true {
//            platforms.append(.HAFacebook)
//        }
        
        print("didFinishLaunchingWithOptions: \(platforms)")

        return true

        
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

