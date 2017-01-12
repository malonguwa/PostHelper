//
//  HATwitterManager.swift
//  PostHelper
//
//  Created by LONG MA on 10/1/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit
import TwitterKit


class HATwitterManager: NSObject {

    
    /// MARK: TweetWithTextandImages
    func sendTweetWithTextandImages(images: [UIImage], text: String?){
        let HATW_userID = Twitter.sharedInstance().sessionStore.session()?.userID
        var mediaIDs = [String]()
        let queue = DispatchQueue(label: "serialQForTWImageUpload")// 创建了一个串行队列
        let client = TWTRAPIClient(userID: HATW_userID!)
        
        for image in images.enumerated() {
            queue.async {//将任务代码块加入异步串行队列queue中
                let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                let imgData = UIImageJPEGRepresentation(image.element, 0.6)
                
                if imgData == nil {
                    print("image data error")
                } else {
                    client.uploadMedia(imgData!, contentType: "image/jpeg", completion: { (mediaID, error) in
                        if error != nil {
                            print("\(image.offset): error uploading media to Twitter \(error)")
                        } else {
                            mediaIDs.append(mediaID!)
                            print(mediaIDs)
                        }
                        semaphore.signal()//当满足条件时，向队列发送信号
                    })
                    semaphore.wait()//阻塞并等待信号
                }
            }
        }//END for
        
        queue.async {
            
            print("start to post")
            let mediaIDArray = mediaIDs
            var combinedStr = ""
            for mediaIDString in mediaIDArray.enumerated() {
                print("in for \(combinedStr)")
                if mediaIDString.offset == mediaIDArray.count - 1{
                    combinedStr = combinedStr.appending("\(mediaIDString.element)")
                    break
                }
                combinedStr = combinedStr.appending("\(mediaIDString.element),")
            }
            print("end for")
//            combinedStr = combinedStr.appending("\"")
            
            print("combinedStr : \(combinedStr)")
            
            var urlError : NSError? = nil
            let params = [
                "status" : text!,
                "media_ids" : combinedStr,
                ] as [String : Any]
            let request = client.urlRequest(withMethod: "POST", url: "https://api.twitter.com/1.1/statuses/update.json", parameters: params, error: &urlError)
            
            if urlError !== nil {
                assert(false, "\(urlError)")
                return
            }
            client.sendTwitterRequest(request, completion: { (response, data, error) in
                
                guard let httpResponse = response as? HTTPURLResponse else{
                    print("\(response)\n\n\(data)\n\n\(error)")
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("Tweet sucessfully")
                } else {
                    print("\(response)\n\n\(data)\n\n\(error)")
                }
            })
            
        }
        
    }
    
    /// MARK: TweetWithTextandVideos
    func sendTweetWithTextAndVideos(images: [UIImage], text: String?){
        
    }
}


/**
 let queue = DispatchQueue(label: "serialQForVideoUpload")// 创建了一个串行队列
 
 var _videos = [NSData]()
 
 for asset in avAssetsForSend.enumerated() {
 queue.async {//将任务代码块加入异步串行队列queue中
 let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
 asset.element.fetchAVAssetWithCompleteBlock({ (av, info) in
 let avurl = av as! AVURLAsset
 if av != nil && asset.element.isVideo == true{
 
 let videoData = NSData(contentsOf: avurl.url)
 _videos.append(videoData!)
 print("1: \(_videos.count)")
 
 semaphore.signal()//当满足条件时，向队列发送信号
 }
 })
 semaphore.wait()//阻塞并等待信号
 }
 }
 
 
 */
