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
            platforms.remove(at:0)
        } else {
            platforms.append(.HATwitter)
        }
        print(platforms)
    }
    
    @IBAction func FBSwitchBtnClick(_ sender: UISwitch) {
        if sender.isOn == false{
            platforms.remove(at:1)
        } else {
            platforms.append(.HAFacebook)
        }
    }
    
    
    override func viewDidLoad() {
        print("HAPlatformSelectionController viewDidLoad")
        view.backgroundColor = UIColor.purple
        
        
//        if hasAuthToTwitter == true && platforms[0] != .HATwitter {
//        }
//        TwitterSwitchBtn.isOn = hasAuthToTwitter!
//        if platforms.count == 0{
//            
//        }
//        
//        
//        FacebookSwitchBtn.isOn = hasAuthToFacebook!

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
        
        if hasAuthToTwitter! == false {
            TwitterSwitchBtn.isOn = false
            TwitterSwitchBtn.isEnabled = false
        }
        
        if hasAuthToFacebook! == false {
            FacebookSwitchBtn.isOn = false
            FacebookSwitchBtn.isEnabled = false
        }
        print(platforms)

        
    }
    
    deinit {
        print("HAPlatformSelectionController deinit")
    }
    
}
