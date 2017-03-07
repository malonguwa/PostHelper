//
//  HAVideo.swift
//  PostHelper
//
//  Created by LONG MA on 16/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAVideo : NSObject {
    var HAvideoURL : URL?
    var HAvideoImage : UIImage?
    var HAvideoSize : Int = 0
    
    
    init(avPlayerItem : AVPlayerItem, coverImage : UIImage) {
        let avurl = avPlayerItem.asset as! AVURLAsset
        HAvideoURL = avurl.url
        HAvideoImage = coverImage
        HAvideoSize = (NSData(contentsOf: avurl.url)?.length)!
    }
    
    internal func printInfo() {
        print("+++video-info:\nvideoURL: \(HAvideoURL)\nvideoImage = \(HAvideoImage)\nvideoSize = \(Double((HAvideoSize)) * 0.000001024) MB)/n+++/n")
//        print("fileSize : \(Double((videoData?.length)!) * 0.000001024) MB")

    }
    
}
