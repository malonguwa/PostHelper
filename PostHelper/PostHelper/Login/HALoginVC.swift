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
import FBSDKCoreKit
import TwitterKit
import Security

// Global var
public var hasAuthToTwitter : Bool?
public var hasAuthToFacebook : Bool?
public var platforms = [SocialPlatform]()
public enum SocialPlatform { // send squence
    case HATwitter
    case HAFacebook
}
//TWImageFinalEND, TWVideoFinalEND, FBImageFinalEND, FBVideoFinalEND

public enum WhoUploadEnd {
    case TWImageFinalEND
    case TWVideoFinalEND
    case FBImageFinalEND
    case FBVideoFinalEND
}

class HALoginVC: UIViewController {

    // MARK: Property
    /// Btn : Add facebook account
    @IBOutlet weak var addFBAccountBtn: UIButton!
    @IBOutlet weak var addTWAccountBtn: UIButton!
    @IBOutlet weak var FBDisconnectBtn: UIButton!
    @IBOutlet weak var TWDisconnectBtn: UIButton!
    @IBOutlet weak var readyBtn: UIButton!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFromParentViewController()
        print("viewWillDisappear")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")

    }
    */
    
    func setTopConstarint() {
        topLayoutConstraint.constant = (view.frame.size.height * 0.5 - 125)
    }
    // MARK: Function
    override func viewDidLoad() {
        super.viewDidLoad()
        setTopConstarint()
//        NotificationCenter.default.addObserver(self, selector: #selector(HALoginVC.HAFacebookCheckLogin), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)

        print(UIScreen.main.bounds)
//        print("HALoginVC\(self)")
        
        //check login state
        print("Twitter session = \(String(describing: Twitter.sharedInstance().sessionStore.session()))")
        print("Facebook AccessToken = \(String(describing: AccessToken.current?.appId)) and expirationDate = \(String(describing: AccessToken.current?.expirationDate))")
        hasAuthToTwitter = HALoginVC.hasAccessToTwitter()
        hasAuthToFacebook = HALoginVC.hasAccessToFacebook()
        
        //setup platforms array for collect login state
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
        

        
        if HALoginVC.hasAccessToFacebook() == false && HALoginVC.hasAccessToTwitter() == false{
            FBDisconnectBtn.isHidden = true
            TWDisconnectBtn.isHidden = true

            readyBtn.isEnabled = false
        } else {

            HALoginVC.hasAccessToFacebook() == true ?  (addFBAccountBtn.isEnabled = false) : (addFBAccountBtn.isEnabled = true)
            addFBAccountBtn.isEnabled = HALoginVC.hasAccessToFacebook() == true ? false : true
            switchAddAccBtnImage(isEnabled: addFBAccountBtn.isEnabled, btn: addFBAccountBtn)
            
            FBDisconnectBtn.isHidden = !HALoginVC.hasAccessToFacebook()

            addTWAccountBtn.isEnabled = HALoginVC.hasAccessToTwitter() == true ? false : true
            switchAddAccBtnImage(isEnabled: addTWAccountBtn.isEnabled, btn: addTWAccountBtn)

            TWDisconnectBtn.isHidden = !HALoginVC.hasAccessToTwitter()
            
            readyBtn.isEnabled = true
        }
        
    }

    func switchAddAccBtnImage (isEnabled : Bool?, btn : UIButton?){
        if isEnabled == false {
            btn?.setImage(UIImage(named: "connect_withRing_green_128"), for: UIControlState.disabled)
        } else {
            btn?.setImage(UIImage(named: "FontAwesome_add_128"), for: UIControlState.normal)
        }
        
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
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
                DispatchQueue.main.async { [weak self] in
                    self?.addFBAccountBtn.isEnabled = false
                    self?.switchAddAccBtnImage(isEnabled: self?.addFBAccountBtn.isEnabled, btn: self?.addFBAccountBtn)

                    self?.FBDisconnectBtn.isHidden = false
                    self?.readyBtn.isEnabled = true
                }
                
                if hasAuthToFacebook! == true {
                    platforms.append(.HAFacebook)
                }
                
                print("Logged in with write permission!, \n\n grantedPermissions: \(grantedPermissions), \n\n declinedPermissions: \(declinedPermissions),\n\n accessToken: \(accessToken)")
               
                //将Token写入KeyChain
                let keychainItem = KeychainPasswordItem.init(service: "PostHelperService", account: "FB_AccesssTokenForShare_Test", accessGroup: "group.com.HnA.PostHelperAPP")
                
                do {
                    try keychainItem.savePassword(accessToken.authenticationToken)
                    print("写入keychain成功")
                } catch {
                    print(error.localizedDescription)
                }
                
                //获取
                
                var passW = ""
                do {
                    try passW = keychainItem.readPassword()
                    print("keychain成功\(passW)")
                } catch {
                    print(error.localizedDescription)
                }
                
                
        }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }
}
    

    
    /// addTWAccountBtn event
    @IBAction func addTWAccountClick(_ sender: Any) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
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
                DispatchQueue.main.async { [weak self] in
                    self?.addTWAccountBtn.isEnabled = false
                    self?.switchAddAccBtnImage(isEnabled: self?.addTWAccountBtn.isEnabled, btn: self?.addTWAccountBtn)

                    self?.TWDisconnectBtn.isHidden = false
                    
                    self?.readyBtn.isEnabled = true

                }
                
                print("signed in as \(String(describing: session?.userName))")
                
            } else {
                print("error : \(String(describing: error?.localizedDescription))")
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
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
            DispatchQueue.main.async { [weak self] in
                self?.addTWAccountBtn.isEnabled = true
                self?.switchAddAccBtnImage(isEnabled: self?.addTWAccountBtn.isEnabled, btn: self?.addTWAccountBtn)

                self?.TWDisconnectBtn.isHidden = true
                platforms.count > 0 ? (self?.readyBtn.isEnabled = true) : (self?.readyBtn.isEnabled = false)
            }
        }
        
    }
    
    @IBAction func FBLogOutClick(_ sender: Any) {
        
        guard let token = AccessToken.current else {
            print("token is nil")
            return
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        GraphRequest(graphPath: "/me/permissions", parameters:[:], accessToken: token, httpMethod: GraphRequestHTTPMethod.DELETE, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
//            print("\(response)\n\(requestResult)")
            if platforms.count != 0 {
                for platform in platforms.enumerated() {
                    if platform.element == .HAFacebook {
                        platforms.remove(at: platform.offset)
                        hasAuthToFacebook = false
//                        print("facebook remove from array \(platforms)")
                    }
                }
            }
            
            switch requestResult {
            case .failed(let error):
                print(error)
                break
            case .success(let response):
                DispatchQueue.main.async { [weak self] in
                    self?.addFBAccountBtn.isEnabled = true
                    self?.switchAddAccBtnImage(isEnabled: self?.addFBAccountBtn.isEnabled, btn: self?.addFBAccountBtn)
                    self?.FBDisconnectBtn.isHidden = true
                    platforms.count > 0 ? (self?.readyBtn.isEnabled = true) : (self?.readyBtn.isEnabled = false)

                }
                print(response)
                break
            }

            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
//            print("Twitter session = nil")
            return false
        } else {
//            print("Twitter session = \(Twitter.sharedInstance().sessionStore.session())")
            return true
        }
    }
    
    public class func hasAccessToFacebook() -> Bool {
        
        if AccessToken.current == nil{
//            print("hasAccessToFacebook(): Facebook AccessToken = nil")
            return false
        } else {
//            print("hasAccessToFacebook(): Facebook AccessToken expirationDate = \(AccessToken.current?.expirationDate)")
            return true
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepare for segue")
////        segue.source.addChildViewController(segue.destination)
////        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(segue.destination)
//    }
    
    deinit {
        print("HALoginVC deinit")
    }
}
