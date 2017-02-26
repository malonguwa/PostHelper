//
//  HASocialPlatformsBaseManager.swift
//  PostHelper
//
//  Created by LONG MA on 1/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

enum uploadStatus {
    case Success
    case Failure
    case Uploading
}


class HASocialPlatformsBaseManager: NSObject {
    
    var PhotoUpdateUploadStatus : ((_ percentage: CGFloat, _ status: uploadStatus) -> ())?
    var VideoUpdateUploadStatus : ((_ percentage: CGFloat, _ status: uploadStatus) -> ())?
    
//    var duplicateTextError : Error?
    
//    var errorMsg : String?
    /*
    func extractTwitterErrorMessage(error: Error) -> String {
        let nse = error as NSError
        let TWErrorStr = "\(nse.userInfo["NSLocalizedFailureReason"]!)\n"
        return TWErrorStr as String
    }
    
    
    func extractFacebookErrorMessage(error: Error) -> String {
        let nse = error as NSError
        let FBErrorStr = "Facebook error: " + "\(nse.userInfo["com.facebook.sdk:FBSDKErrorLocalizedErrorTitleKey"]!)"
        return FBErrorStr as String
    }
 */
    /*
    func goToNextPlatform(sendToPlatforms: [SocialPlatform]!, errorMessage: String?, completion: (([SocialPlatform], String?)->())?) {
        
//        print("goToNextPlatform: \(error)")
        var array_platforms = [SocialPlatform]()
        array_platforms.append(contentsOf: sendToPlatforms)
        array_platforms.remove(at: 0)
        print("array_platforms: \(array_platforms)")
        if errorMessage == nil {
            completion!(array_platforms, nil)
        } else {
            completion!(array_platforms, errorMessage!)
        }
        
    }
    */
    
    deinit {
        print("HASocialPlatformsBaseManager deinit")
    }
    
    
    
    
    
    
    
    
}
