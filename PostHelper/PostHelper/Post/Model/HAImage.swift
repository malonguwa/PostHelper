//
//  HAImage.swift
//  PostHelper
//
//  Created by LONG MA on 16/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAImage : NSObject {
    var HAimage : UIImage?
    var HAimageSize : Int = 0
    
    
    init(image : UIImage) {
        HAimage = image
        HAimageSize = (UIImageJPEGRepresentation(image, 1.0)?.count)!
    }
    
    internal func printInfo() {
        print("+++image-info:\nimage: \(HAimage)\nvimageSize = \(CGFloat(HAimageSize) / 1024.00)kb/n+++/n")
    }

    
    
    
}
