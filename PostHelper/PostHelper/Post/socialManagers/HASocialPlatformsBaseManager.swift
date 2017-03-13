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
    
    
   class func sendPostStatusNotification(isSuccess: Bool, currentPlatform: SocialPlatform, isVideo: Bool) {
        let postStatus: Dictionary<String, Any> = [
            "isSuccess" : isSuccess,
            "currentPlatform" : currentPlatform,
            "isVideo" : isVideo
        ]
        
        let notification = Notification.init(name: Notification.Name(rawValue: "HApostStatusUpdateNotification"), object: nil, userInfo: postStatus)
        
        NotificationCenter.default.post(notification)
    }
    
    
    class func sendFinalPostStatusNotification(isEnd: Bool, currentPlatform: SocialPlatform, whoEnd: WhoUploadEnd, isFinalRequestSucess: Bool) {
        //FIXME: 未完成
        //这个通知加上后，还没有做内存检测
        //增加参数负责让进度面板知道到底是哪个平台的Image or Video结束了, eg. "whoFinalEND" : "TWImageFinalEND"
        //TWImageFinalEND, TWVideoFinalEND, FBImageFinalEND, FBVideoFinalEND
        
        let postStatus: Dictionary<String, Any> = [
            "isEnd" : isEnd,
            "currentPlatform" : currentPlatform,
            "whoFinalEND" : whoEnd,
            "isFinalRequestSucess" : isFinalRequestSucess
        ]
        
        let notification = Notification.init(name: Notification.Name(rawValue: "HAfinalPostStatusNotification"), object: nil, userInfo: postStatus)
        
        NotificationCenter.default.post(notification)
    }
    
    
    deinit {
        print("HASocialPlatformsBaseManager deinit")
    }
    
    
    
    
    
    
    
    
}
