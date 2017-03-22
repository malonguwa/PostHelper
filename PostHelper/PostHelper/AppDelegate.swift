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



extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func savePostHelperAdvanturePlistInfo() {
        //FIXME: 从沙盒中寻找PostHelperAdvanture.plist文件
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachePath = paths[0]
        let PHA_PlistPath = cachePath + "/PostHelperAdvanture.plist"
        
        print("cachePath: \(PHA_PlistPath)")
        
        let fm = FileManager.default
        if fm.fileExists(atPath: PHA_PlistPath) == true {
            //找到 - 不是第一次
            //将plist里面的数据缓存到内存中（全局变量）
            print("找到 PostHelperAdvanture.plist")
        } else {
            //没找到 - 第一次
            print("没找到 PostHelperAdvanture.plist")
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            //创建Plist - PostHelperAdvanture.plist
            let plistCreateResult = fm.createFile(atPath: PHA_PlistPath, contents: nil, attributes: nil)
            //写入数据
            if plistCreateResult == true {
                let dict = NSMutableDictionary()
                //创建Key - weFirstMetOn Value - time(日/月/年)
                //创建Key - FbPostImageCount Value - Int
                //创建Key - FbPostVideoCount Value - Int
                //创建Key - TwPostImageCount Value - Int
                //创建Key - TwPostVideoCount Value - Int
                dict.setValue(0, forKey: "firstTime")
                dict.setValue("\(dateFormatter.string(from: now))", forKey: "weFirstMetOn")
                dict.setValue(0, forKey: "FbPostImageCount")
                dict.setValue(0, forKey: "FbPostVideoCount")
                dict.setValue(0, forKey: "TwPostImageCount")
                dict.setValue(0, forKey: "TwPostVideoCount")
                
                dict.write(toFile: PHA_PlistPath, atomically: true)
            }
        }
        
    }
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


        savePostHelperAdvanturePlistInfo()
        
        
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
            let topViewController = UIApplication.shared.topMostViewController()
            print("1.------\(topViewController)")
            if (topViewController?.isKind(of: HALoginVC.self))! && platforms.count > 0 {
                print("2.------\(topViewController)")
                topViewController?.performSegue(withIdentifier: "HA_loginToPost", sender: nil)
            } else if (topViewController?.childViewControllers.count)! > 0 && (topViewController?.childViewControllers[0].isKind(of: HASidePanel.self))! && platforms.count > 0 {
                print("3.------\(topViewController)")
                NotificationCenter.default.post((topViewController?.childViewControllers[0] as! HASidePanel).sidePanelRemoveAnimationNotify)
            }
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

