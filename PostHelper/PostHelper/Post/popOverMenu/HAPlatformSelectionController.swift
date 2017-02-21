//
//  HAPlatformSelectionController.swift
//  PostHelper
//
//  Created by LONG MA on 18/1/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAPlatformSelectionController: UIViewController {
    @IBOutlet weak var FacebookSwitchBtn: UISwitch!
    @IBOutlet weak var TwitterSwitchBtn: UISwitch!
    weak var platformBtn: UIButton!
    weak var sendDisableBtn: UIButton!
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
    
    
    override func viewDidLoad() {
//        print("HAPlatformSelectionController viewDidLoad")
        view.backgroundColor = UIColor.purple
        
//        HALoginVC.setPlatformsInOrder()
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
            TwitterSwitchBtn.isOn = false
            TwitterSwitchBtn.isEnabled = false
        }
        
        if hasAuthToFacebook! == false {
            FacebookSwitchBtn.isOn = false
            FacebookSwitchBtn.isEnabled = false
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
    
    class func disableSendBtn(sendBtn: UIButton, displayCount: Int) {

        if platforms.count > 0 && displayCount > 0{
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
    }
    
    deinit {
        HAPlatformSelectionController.switchPlatformImage(button: platformBtn)
        HAPlatformSelectionController.disableSendBtn(sendBtn: sendDisableBtn, displayCount: displayArrayCount)
        print("HAPlatformSelectionController deinit")
    }
    
}
