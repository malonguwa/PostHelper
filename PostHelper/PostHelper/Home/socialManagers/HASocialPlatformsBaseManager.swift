//
//  HASocialPlatformsBaseManager.swift
//  PostHelper
//
//  Created by LONG MA on 1/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HASocialPlatformsBaseManager: NSObject {
    
    var updateUploadStatus : ((_ percentage: String, _ success: Bool) -> ())?
    
    func goToNextPlatform(sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform])->())?) {
        var array_platforms = [SocialPlatform]()
        array_platforms.append(contentsOf: sendToPlatforms)
        array_platforms.remove(at: 0)
        print("array_platforms: \(array_platforms)")
        completion!(array_platforms)
    }
    
    
    
    
    
    
    
    
}
