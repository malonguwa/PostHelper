//
//  HALoginVC.swift
//  PostHelper
//
//  Created by LONG MA on 15/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import SafariServices
import FBSDKCoreKit
import TwitterKit

class HALoginVC: UIViewController, SFSafariViewControllerDelegate {

    // MARK: Property
    /// Btn : Add facebook account
    @IBOutlet weak var addFBAccountBtn: UIButton!
    @IBOutlet weak var addTWAccountBtn: UIButton!
    @IBOutlet weak var FBDisconnectBtn: UIButton!
    @IBOutlet weak var TWDisconnectBtn: UIButton!
    @IBOutlet weak var readyBtn: UIButton!
    
    // MARK: Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HALoginVC.HAFacebookCheckLogin), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)

        hasAuthToTwitter = HALoginVC.hasAccessToTwitter()
        hasAuthToFacebook = HALoginVC.hasAccessToFacebook()
        
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

        print("HALoginVC viewDidLoad: \(platforms)")
        
        if HALoginVC.hasAccessToFacebook() == false {
            addFBAccountBtn.isEnabled = true
            FBDisconnectBtn.isEnabled = false
            readyBtn.isEnabled = false
        } else {
            addFBAccountBtn.isEnabled = false
            FBDisconnectBtn.isEnabled = true
            readyBtn.isEnabled = true
        }
        
        if HALoginVC.hasAccessToTwitter() == false {
            addTWAccountBtn.isEnabled = true
            TWDisconnectBtn.isEnabled = false
            readyBtn.isEnabled = false
        } else {
            addTWAccountBtn.isEnabled = false
            TWDisconnectBtn.isEnabled = true
            readyBtn.isEnabled = true
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func HAFacebookCheckLogin() {
        if AccessToken.current != nil {// User is already logged in, do work such as go to next view controller.
            print("~~~******** Connected to facebook already\n")
        } else {
            print("~~~Not connect to facebook")
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Btn Event
    /// addFBAccountBtn event
    @IBAction func addFBAccountClick(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.loginBehavior = .native
        loginManager.logIn([.publishActions], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                hasAuthToFacebook = true
                DispatchQueue.main.async {
                    self.addFBAccountBtn.isEnabled = false
                    self.FBDisconnectBtn.isEnabled = true
                    self.readyBtn.isEnabled = true
                }
                
                if hasAuthToFacebook! == true {
                    platforms.append(.HAFacebook)
                }
                
                print("Logged in with write permission!, \n\n grantedPermissions: \(grantedPermissions), \n\n declinedPermissions: \(declinedPermissions),\n\n accessToken: \(accessToken)")
        }
    }
}
    
    /// addTWAccountBtn event
    @IBAction func addTWAccountClick(_ sender: Any) {
        Twitter.sharedInstance().logIn { (session, error) in
            if session != nil {
                
                hasAuthToTwitter = HALoginVC.hasAccessToTwitter()
                
//                if hasAuthToTwitter == true && hasAuthToFacebook == true && platforms[0] != .HATwitter {
//                    platforms.insert(.HATwitter, at: 0)
//                }
                
                if platforms.count != 0 {
                    if hasAuthToTwitter == true && platforms[0] != .HATwitter {
                        platforms.insert(.HATwitter, at: 0)
                    }
                    
                    
                } else {
                    if hasAuthToTwitter == true {
                        platforms.append(.HATwitter)
                    }
                }
                DispatchQueue.main.async {
                    self.addTWAccountBtn.isEnabled = false
                    self.TWDisconnectBtn.isEnabled = true
                    self.readyBtn.isEnabled = true

                }
                
                print("signed in as \(session?.userName)")
                
            } else {
                print("error : \(error?.localizedDescription)")
            }
        }
    }
    
    
    
    
    
    
    
    
//        loginManager.logIn([.publicProfile, ReadPermission.custom("user_photos"), ReadPermission.custom("user_videos")], viewController: self) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//
//                print("Logged in with read permission!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
//                loginManager.logIn([.publishActions], viewController: self) { loginResult in
//                    switch loginResult {
//                    case .failed(let error):
//                        print(error)
//                    case .cancelled:
//                        print("User cancelled login.")
//                    case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//
//                        print("Logged in with read permission!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
//                    }
//
//                }
//            }
//        }
        
//        .custom("user_photos")
//        loginManager.logIn([.publishActions], viewController: self) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//
//                print("Logged in with read permission!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
//            }
//
        

        
        
        

    @IBAction func TWLogOutClick(_ sender: Any) {
        let store = Twitter.sharedInstance().sessionStore
        if platforms.count != 0 {
            for platform in platforms.enumerated() {
                if platform.element == .HATwitter {
                    platforms.remove(at: platform.offset)
                    hasAuthToTwitter = false
                }
            }
        }
        
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
            print(store.existingUserSessions())
            DispatchQueue.main.async {
                self.addTWAccountBtn.isEnabled = true
                self.TWDisconnectBtn.isEnabled = false
                platforms.count > 0 ? (self.readyBtn.isEnabled = true) : (self.readyBtn.isEnabled = false)
            }
        }
        
    }
    
    @IBAction func FBLogOutClick(_ sender: Any) {
        
        guard let token = AccessToken.current else {
            print("token is nil")
            return
        }
        
//        let safariVC = SFSafariViewController.init(url: URL(string: "https://www.facebook.com/logout.php?next=https://example.com&access_token=\(token.authenticationToken)")!)
//        // https://www.facebook.com/logout.php?next=http://example.com&access_token=xxx
//
//        safariVC.delegate = self
//        present(safariVC, animated: true, completion: {
//            
//        })
        
        

        GraphRequest(graphPath: "/me/permissions", parameters:[:], accessToken: token, httpMethod: GraphRequestHTTPMethod.DELETE, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
//            print("\(response)\n\(requestResult)")
            if platforms.count != 0 {
                for platform in platforms.enumerated() {
                    if platform.element == .HAFacebook {
                        platforms.remove(at: platform.offset)
                        hasAuthToFacebook = false
                        print("facebook remove from array \(platforms)")
                    }
                }
            }
            
            switch requestResult {
            case .failed(let error):
                print(error)
                break
            case .success(let response):
                DispatchQueue.main.async {
                    self.addFBAccountBtn.isEnabled = true
                    self.FBDisconnectBtn.isEnabled = false
                    platforms.count > 0 ? (self.readyBtn.isEnabled = true) : (self.readyBtn.isEnabled = false)

                }
                print(response)
                break
            }

        }
        
        let loginManager = LoginManager()
        loginManager.logOut()

    }
    
    public class func setPlatformsInOrder() {
        if platforms.count != 0 {
            if hasAuthToTwitter == true && hasAuthToFacebook == true && platforms[0] != .HATwitter {
                platforms.insert(.HATwitter, at: 0)
            }
        } else {
            if hasAuthToTwitter == true {
                platforms.append(.HATwitter)
            }
            if hasAuthToFacebook == true {
                platforms.append(.HAFacebook)
            }
        }
    
    }
    
    public class func hasAccessToTwitter() -> Bool {
        if Twitter.sharedInstance().sessionStore.session() == nil {
            print("Twitter session = nil")
            return false
        } else {
            print("Twitter session = \(Twitter.sharedInstance().sessionStore.session())")
            return true
        }
    }
    
    public class func hasAccessToFacebook() -> Bool {
        
        if AccessToken.current == nil{
            print("hasAccessToFacebook(): Facebook AccessToken = nil")
            return false
        } else {
            print("hasAccessToFacebook(): Facebook AccessToken expirationDate = \(AccessToken.current?.expirationDate)")
            return true
        }
    }

    deinit {
        print("HALoginVC deinit")
    }
}
