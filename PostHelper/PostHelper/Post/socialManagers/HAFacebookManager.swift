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

class HAFacebookManager: HASocialPlatformsBaseManager {
    
    // MARK: FB - Send Text Only
    func sendTextOnly(text : String!, sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform], Error?)->())?) {
        
        if sendToPlatforms.count == 0 {// Only send to Twitter
            completion!(sendToPlatforms, nil)
            return
        }
        
        for platform in sendToPlatforms {// Only send to Facebook
            if platform == .HAFacebook {
                break
            } else {
                completion!(sendToPlatforms, nil)
                return
            }
        }
        
        
        GraphRequest(graphPath: "/me/feed", parameters:["message" : text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion).start { (response, result) in
            //text send completely
//            print("text send completely + \(response)\n")
            print("Facebook text send completely\n")

            switch result {
            case .failed(let error):
                // Handle the result's error
                self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: error, completion:completion)
                break
                
            case .success(_):
                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: nil, completion:completion)
            }
            
        }
    }

    
    
    
    
    
    
    
    
}
