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
//            print("request: \(FBSDKGraphRequestConnection)\n data: \(data)\n Error: \(Error)")
            if Error == nil {
                completion!(nil)
            } else {
//                print("facebook Error: \(Error)")
                completion!(Error?.localizedDescription)
            }
        
        }
        
/*
         let request = GraphRequest(graphPath: "/me/feed", parameters:["message" : text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
     request.start { (response, result) in
            //text send completely
//            print("text send completely + \(response)\n")

    
        
            switch result {
            case .failed(let error):
//            case .failed(_):
//                let nse = error as NSError
//                let FBErrorStr = "Facebook error: " + "\(nse.userInfo["com.facebook.sdk:FBSDKErrorLocalizedErrorTitleKey"]!)"
//                completion!(FBErrorStr)
                
//                var nse : NSError?
//                nse = error as NSError?
//                var FBErrorStr : String?
//                FBErrorStr = "Facebook error: " + "\(nse?.userInfo["com.facebook.sdk:FBSDKErrorLocalizedErrorTitleKey"]!)"
//                
//                self.FacebookErrorStr = FBErrorStr!
//                
//                FBErrorStr = nil
//                nse = nil
//                self.FacebookErrorStr = self.extractFacebookErrorMessage(error: error)
                
//                print(error.localizedDescription)
                
//                self.FacebookErrorStr = error.localizedDescription
                
                print("Facebook Error")

//                self?.FacebookErrorStr = "FB error"

                completion!("fail to post")

                return
                
            case .success(_):
                print("Facebook text send completely\n")
                completion!(nil)

            }
        
        
            
        }
 */
     
    }

    
    
    deinit {
        print("HAFacebookManager deinit")
    }
    
    
    
    
}
