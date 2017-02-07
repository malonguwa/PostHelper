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
    
    var duplicateTextError : Error?
    
    func goToNextPlatform(sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform])->())?) {
        var array_platforms = [SocialPlatform]()
        array_platforms.append(contentsOf: sendToPlatforms)
        array_platforms.remove(at: 0)
        print("array_platforms: \(array_platforms)")
        completion!(array_platforms)
        
    }
    
    
    
    
    
    
    
    
}
