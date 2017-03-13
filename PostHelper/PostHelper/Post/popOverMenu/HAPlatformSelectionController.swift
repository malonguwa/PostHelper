//
//  HAPlatformSelectionController.swift
//  PostHelper
//
//  Created by LONG MA on 18/1/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import TwitterKit

class HAPlatformSelectionController: UIViewController {
    @IBOutlet weak var FacebookSwitchBtn: UISwitch!
    @IBOutlet weak var TwitterSwitchBtn: UISwitch!
    @IBOutlet weak var FacebookAddBtn: UIButton!
    @IBOutlet weak var TwitterAddBtn: UIButton!
    
    weak var LoginVC: HALoginVC!
    weak var platformBtn: UIButton!
    weak var sendDisableBtn: UIButton!
    var textForSend: String!
    var displayArrayCount = 0
    
    @IBAction func TWSwitchBtnClick(_ sender: UISwitch) {
        if sender.isOn == false{
            for platform in platforms.enumerated() {
                if platform.element == .HATwitter {
                    platforms.remove(at: platform.offset)
                }
            }
            
        } else {
            if platforms.count == 0{
                if hasAuthToTwitter == true {
                    print("\(hasAuthToTwitter)")
                    platforms.insert(.HATwitter, at: 0)
                }
            } else {
                if hasAuthToTwitter == true && platforms[0] != .HATwitter{
                    print("\(hasAuthToTwitter)")
                    platforms.insert(.HATwitter, at: 0)
                }
            }
        }
        print("TWSwitchBtnClick - \(platforms)")
    }
    
    @IBAction func FBSwitchBtnClick(_ sender: UISwitch) {
        if sender.isOn == false{
            for platform in platforms.enumerated() {
                if platform.element == .HAFacebook {
                    platforms.remove(at: platform.offset)
                }
            }
        } else {

            if hasAuthToFacebook == true {
                print("\(hasAuthToFacebook)")
                platforms.append(.HAFacebook)
            }
            
            
            
            
        }
        print("FBSwitchBtnClick - \(platforms)")
    }
    
    @IBAction func TWAddBtnClick(_ sender: Any) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Twitter.sharedInstance().logIn { (session, error) in
            if session != nil {
                
                hasAuthToTwitter = HALoginVC.hasAccessToTwitter()
                
                if platforms.count != 0 {
                    if hasAuthToTwitter == true && platforms[0] != .HATwitter {
                        platforms.insert(.HATwitter, at: 0)
                    }
                    
                    
                } else {
                    if hasAuthToTwitter == true {
                        platforms.append(.HATwitter)
                    }
                }
                
                self.TwitterAddBtn.isHidden = true
                self.TwitterSwitchBtn.isHidden = false
                self.TwitterSwitchBtn.isOn = true
                
                DispatchQueue.main.async { [weak self] in
                    self?.LoginVC.addTWAccountBtn.isEnabled = false
                    self?.LoginVC.switchAddAccBtnImage(isEnabled: self?.LoginVC.addTWAccountBtn.isEnabled, btn: self?.LoginVC.addTWAccountBtn)
                    self?.LoginVC.TWDisconnectBtn.isHidden = false
                    self?.LoginVC.readyBtn.isEnabled = true   
                }
                
                print("signed in as \(session?.userName)")
                
            } else {
                print("error : \(error?.localizedDescription)")
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

        
        
    }
    
    
    @IBAction func FBAddBtnClick(_ sender: Any) {
        
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
                self.FacebookAddBtn.isHidden = true
                self.FacebookSwitchBtn.isHidden = false
                self.FacebookSwitchBtn.isOn = true
                
                DispatchQueue.main.async { [weak self] in
                    
                    self?.LoginVC.addFBAccountBtn.isEnabled = false
                    self?.LoginVC.switchAddAccBtnImage(isEnabled: self?.LoginVC.addFBAccountBtn.isEnabled, btn: self?.LoginVC.addFBAccountBtn)
                    self?.LoginVC.FBDisconnectBtn.isHidden = false
                    self?.LoginVC.readyBtn.isEnabled = true
                }
                
                if hasAuthToFacebook! == true {
                    platforms.append(.HAFacebook)
                }
                
                print("Logged in with write permission!, \n\n grantedPermissions: \(grantedPermissions), \n\n declinedPermissions: \(declinedPermissions),\n\n accessToken: \(accessToken)")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }

        
    }
    
    override func viewDidLoad() {
//        print("HAPlatformSelectionController viewDidLoad")
//        view.backgroundColor = UIColor.purple
//        HALoginVC.setPlatformsInOrder()
        
        print(LoginVC)
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
        
        if hasAuthToTwitter! == false {
//            TwitterSwitchBtn.isOn = false
//            TwitterSwitchBtn.isEnabled = false
            TwitterSwitchBtn.isHidden = true
            TwitterAddBtn.isHidden = false
        }
        
        if hasAuthToFacebook! == false {
//            FacebookSwitchBtn.isOn = false
//            FacebookSwitchBtn.isEnabled = false
            FacebookSwitchBtn.isHidden = true
            FacebookAddBtn.isHidden = false
        }
//        print("viewDidLoad - \(platforms)")

        
    }
    
    
   class func switchPlatformImage(button: UIButton) {
        if platforms.count > 0 {
            if platforms[0] == .HATwitter && platforms.count == 1{
                button.backgroundColor = UIColor(colorLiteralRed: 0.0/255.0, green: 162.0/255.0, blue: 236.0/255.0, alpha: 1.0)
                button.setImage(UIImage(named: "snow_bird_64"), for: UIControlState.normal)
            } else if platforms[0] == .HAFacebook && platforms.count == 1{
                button.backgroundColor = UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                button.setImage(UIImage(named: "Snow_F_64"), for: UIControlState.normal)
            } else if platforms.count == 2 {
                button.setImage(UIImage(named: "twitter_and_facebook"), for: UIControlState.normal)
            }
        } else { // == 0
            button.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            button.setImage(UIImage(named: "?_snow_64"), for: UIControlState.normal)
        }
    
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit

    }
    
    class func disableSendBtn(sendBtn: UIButton, displayCount: Int, text: String) {

//        print(displayCount)
//        print(text)
//
//        if platforms.count > 0 && displayCount > 0{
//            sendBtn.isEnabled = true
//            
//        } else if platforms.count > 0 && text.characters.count != 0 {
//            sendBtn.isEnabled = true
//
//        } else {
//            sendBtn.isEnabled = false
//        }
        
        
        if platforms.count > 0 {
            if displayCount > 0 || text.characters.count > 0 {
                sendBtn.isEnabled = true
            }
        } else {//==0
            sendBtn.isEnabled = false
        }
    }
    
    deinit {
        HAPlatformSelectionController.switchPlatformImage(button: platformBtn)
        HAPlatformSelectionController.disableSendBtn(sendBtn: sendDisableBtn, displayCount: displayArrayCount, text: textForSend)
        print("HAPlatformSelectionController deinit")
    }
    
}
