//
//  HAFacebookManager.swift
//  PostHelper
//
//  Created by LONG MA on 24/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookShare
import FBSDKCoreKit

class HAFacebookManager: HASocialPlatformsBaseManager {
    
    var FacebookErrorStr : String?

    // MARK: FB - Send Text Only
    func sendTextOnly(text : String!, completion: ((String?)->())?) {
        
        if platforms.count == 0 {
            completion!(nil)
            return
        }
        
        if platforms.contains(.HAFacebook) == false {
            completion!(nil)
            return

        }
    
       let fbsdRequest = FBSDKGraphRequest(graphPath: "/me/feed", parameters: ["message" : text], httpMethod: "POST")
       fbsdRequest?.setGraphErrorRecoveryDisabled(true)
       let _ = fbsdRequest?.start { (FBSDKGraphRequestConnection, data, Error) in
            if Error == nil {
                print("facebook post sucessfully")
                completion!(nil)
            } else {
                completion!("Facebook error : " + (Error?.localizedDescription)!)
            }
        
        }
    }

    
    
    deinit {
        print("HAFacebookManager deinit")
    }
    
    
    
    
}
