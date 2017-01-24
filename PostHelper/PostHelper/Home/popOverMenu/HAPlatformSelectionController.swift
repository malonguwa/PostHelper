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
        print("HAPlatformSelectionController viewDidLoad")
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
        print("viewDidLoad - \(platforms)")

        
    }
    
    deinit {
        print("HAPlatformSelectionController deinit")
    }
    
}
