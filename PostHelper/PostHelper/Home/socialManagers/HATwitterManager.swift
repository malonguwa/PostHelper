//
//  HATwitterManager.swift
//  PostHelper
//
//  Created by LONG MA on 10/1/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit
import TwitterKit
import DKImagePickerController


class HATwitterManager: NSObject {
    let uploadURL = "https://upload.twitter.com/1.1/media/upload.json"
    let statusURL = "https://api.twitter.com/1.1/statuses/update.json"
    /// MARK: TweetWithTextandImages
    func sendTweetWithTextandImages(images: [UIImage], text: String?,sendToSinglePlatform: Bool, completion: (()->())?){
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
            print("combinedStr : \(combinedStr)")
            print("end for")
            
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
                    
                
                    completion!()
                } else {
                    print("\(response)\n\n\(data)\n\n\(error)")
                }
            })
            
        }
        
    }


    /// MARK: TweetWithTextandVideos
    func sendTweetWithTextandVideos(avAssetsForSend: [DKAsset], text: String?) {

        let accountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        guard let accounts = accountStore.accounts(with: accountType) else {
            print("account = nil")
            return
        }
        
        
        let queue = DispatchQueue(label: "serialQForTWVideoUpload")// 创建了一个串行队列
        
        var _videos = [NSData]()
        
        // step 0: 将DKAsset对象中的video.url转化成NSData
        for asset in avAssetsForSend.enumerated() {
            queue.async {//将任务代码块加入异步串行队列queue中
                let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                asset.element.fetchAVAssetWithCompleteBlock({ (av, info) in
                    let avurl = av as! AVURLAsset
                    if av != nil && asset.element.isVideo == true{
                        let videoData = NSData(contentsOf: avurl.url)
                        if videoData == nil{
                            print("data == nil")
                            semaphore.signal()//当满足条件时，向队列发送信号
                        }
                        _videos.append(videoData!)
                        print("1: \(_videos.count)")
                        
                        semaphore.signal()//当满足条件时，向队列发送信号
                    }
                })
                semaphore.wait()//阻塞并等待信号
            }
        }//end for
        
        queue.async(flags: .barrier) {
            for videoData in _videos {
                
            SocialVideoHelper.uploadTwitterVideo(videoData as Data!, comment: text, account: accounts[0] as! ACAccount, withCompletion: { (success, errorMessage) in
                if success == true {
                    print("video upload success")
                } else {
                    print(errorMessage!)
                }
            })
                
                
            }//end for
        }
    }

}
  /**
    func uploadTwitterVideo(avAssetsForSend: [DKAsset], text: String?) {
        let HATW_userID = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: HATW_userID!)
        var mediaIDs = [String]()
        
        let queue = DispatchQueue(label: "serialQForTWVideoUpload")// 创建了一个串行队列
        
        var _videos = [NSData]()
        
        // step 0: 将DKAsset对象中的video.url转化成NSData
        for asset in avAssetsForSend.enumerated() {
            queue.async {//将任务代码块加入异步串行队列queue中
                let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                asset.element.fetchAVAssetWithCompleteBlock({ (av, info) in
                    let avurl = av as! AVURLAsset
                    if av != nil && asset.element.isVideo == true{
                        let videoData = NSData(contentsOf: avurl.url)
                        if videoData == nil{
                            print("data == nil")
                            semaphore.signal()//当满足条件时，向队列发送信号
                        }
                        _videos.append(videoData!)
                        print("1: \(_videos.count)")
                        
                        semaphore.signal()//当满足条件时，向队列发送信号
                    }
                })
                semaphore.wait()//阻塞并等待信号
            }
        }//end for
        
        print("End step 0")
        
        // step 1: INIT
        queue.async {
            for videoData in _videos {
                let INIT_Params = [
                    "command" : "INIT",
                    "total_bytes" : "\(videoData.length)",
                    "media_type" : "video/mp4"
                    ] as [String : Any]
                
                var urlError : NSError? = nil
                let request = client.urlRequest(withMethod: "POST", url: self.uploadURL, parameters: INIT_Params, error: &urlError)
                client.sendTwitterRequest(request, completion: { (response, data, error) in
                    if error != nil {
                        print("step 1: sendTwitterRequest ERROR: \(error)")
                    } else {
                        var mediaID = ""
                        do {
                            let returnedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! NSDictionary
                            mediaID = returnedData["media_id_string"] as! String
                        }catch {
                            print("json error: \(error.localizedDescription)")
                        }
                        
                        self.twitterVideoStage2(videoData: videoData, mediaID: mediaID, text: text, client: client)
                    }
                })
            }//end for
        }
    }
    
    // step 2: APPEND
    func twitterVideoStage2(videoData: NSData, mediaID: String, text: String?, client: TWTRAPIClient) {
        let chunks = separateToMultipartData(videoData: videoData)
        var requests = [URLRequest]()
 
        for i in 0...chunks.count {
            let seg_index = "\(i)"
            let APPEND_Params = [
                "command" : "APPEND",
                "media_id" : mediaID,
                "segment_index" : seg_index
                ] as [String : Any]
            
            let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, url: nil, parameters: APPEND_Params)
            
            
        }
        
    }
    
    
    
    func separateToMultipartData(videoData: NSData) -> Array<NSData> {
        var multipartData = [NSData]()
        let length = CGFloat(videoData.length)
        let standard_length = CGFloat(1000 * 1000 * 5)

        if length <= standard_length {
            multipartData.append(videoData)
            print("need not separate as chunk, data size -> \(CLong(videoData.length)) bytes")
        } else {
            let count = ceil(length/standard_length)
            for i in stride(from: CGFloat(0), to: count, by: 1){
                var range : NSRange
                if i == count - 1 {
                    let v1 = i * standard_length
                    let v2 = length - i * standard_length
                    range = NSMakeRange(Int(v1), Int(v2))
                } else {
                    let v1 = i * standard_length
                    let v2 = standard_length
                    range = NSMakeRange(Int(v1), Int(v2))
                }
                
                let part_data = NSData.init(data: videoData.subdata(with: range))
                multipartData.append(part_data)
                print("chunk index -> \(Int(i)+1), data size -> \(part_data.length) bytes")
            }
            
        }
        return multipartData
    }
    /**
    + (NSArray*)separateToMultipartData:(NSData*)videoData{
        NSMutableArray *multipartData = [NSMutableArray new];
        CGFloat length = videoData.length;
        CGFloat standard_length = Video_Chunk_Max_size;
        if (length <= standard_length) {
            [multipartData addObject:videoData];
            NSLog(@"need not separate as chunk, data size -> %ld bytes", (long)videoData.length);
        } else {
            NSUInteger count = ceil(length/standard_length);
            for (int i = 0; i < count; i++) {
                NSRange range;
                if (i == count - 1) {
                    range = NSMakeRange(i * standard_length, length - i * standard_length);
                } else {
                    range = NSMakeRange(i * standard_length, standard_length);
                }
                NSData *part_data = [videoData subdataWithRange:range];
                [multipartData addObject:part_data];
                NSLog(@"chunk index -> %d, data size -> %ld bytes", (i+1), (long)part_data.length);
            }
        }
        return multipartData.copy;
    }
    */
    
    
    /**
    func sendTWvideos(avAssetsForSend: [DKAsset], text: String?) {
        let HATW_userID = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: HATW_userID!)
        var mediaIDs = [String]()
        
        let queue = DispatchQueue(label: "serialQForTWVideoUpload")// 创建了一个串行队列
        
        var _videos = [Data]()
        
        for asset in avAssetsForSend.enumerated() {
            queue.async {//将任务代码块加入异步串行队列queue中
                let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                asset.element.fetchAVAssetWithCompleteBlock({ (av, info) in
                    let avurl = av as! AVURLAsset
                    if av != nil && asset.element.isVideo == true{
                        var data : Data!
                        do{
                            let videoData = try Data(contentsOf: avurl.url)
                            data = videoData
                        }
                        catch let error{
                            print("videoData: \(error)")
                        }
//                        let videoData = NSData(contentsOf: avurl.url)
                        _videos.append(data)
                        print("1: \(_videos.count)")
                        
                        semaphore.signal()//当满足条件时，向队列发送信号
                    }
                })
                semaphore.wait()//阻塞并等待信号
            }
        }
        
        queue.async { //将任务代码块加入异步串行队列queue中
            print("2: end-for")
//            let queue2 = DispatchQueue(label: "qForTWVideosUploadSquence")
            //发请求
            //            var flagForVideosUpload = 0
            for videoData in _videos.enumerated() {
                let semaphore2 = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                print( "total_bytes : \(videoData.element.count)")
                
                client.uploadMedia(videoData.element, contentType: "video/m4v", completion: { (mediaID, error) in
                    if error != nil {
                        print("~~~~~~~\(videoData.offset): error uploading video to Twitter \(error)")
                    } else {
                        print(mediaID!)
                        mediaIDs.append(mediaID!)
                    }
                    semaphore2.signal()

                })
                semaphore2.wait()
            }//END for
        }//END queue
        
        queue.async(flags: .barrier) {
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
            print("combinedStr : \(combinedStr)")
            print("end for")
            var input = ""
            if text == nil {
            } else {
                input = text!
            }
            var urlError : NSError? = nil
            let params = [
                "status" : input,
                "media_ids" : combinedStr,
                ] as [String : Any]
            let request = client.urlRequest(withMethod: "POST", url: "https://api.twitter.com/1.1/statuses/update.json", parameters: params, error: &urlError)
            
            if urlError !== nil {
                assert(false, "\(urlError)")
                return
            }
            client.sendTwitterRequest(request, completion: { (response, data, error) in
                
                guard let httpResponse = response as? HTTPURLResponse else{
                    print("Tweet:\(response)\n\n\(data)\n\n\(error)")
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("Tweet sucessfully")
                } else {
                    print("Tweet:\(response)\n\n\(data)\n\n\(error)")
                }
            })
        }
    }
    */
    
    
    
    /// MARK: TweetWithTextandVideos
    func sendTweetWithTextAndVideos(avAssetsForSend: [DKAsset], text: String?){
        let HATW_userID = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: HATW_userID!)
        
        let queue = DispatchQueue(label: "serialQForTWVideoUpload")// 创建了一个串行队列
        
        var _videos = [NSData]()
        
        for asset in avAssetsForSend.enumerated() {
            queue.async {//将任务代码块加入异步串行队列queue中
                let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                asset.element.fetchAVAssetWithCompleteBlock({ (av, info) in
                    let avurl = av as! AVURLAsset
                    if av != nil && asset.element.isVideo == true{
                        print("avurl.url:\(avurl.url.relativePath)")

                        let videoData = try! Data(contentsOf: avurl.url, options: Data.ReadingOptions.init(rawValue: 0))
//                            NSData(contentsOfFile: avurl.url.relativePath)
//                        let videoData = NSData(contentsOf: avurl.url)
                        print("videoData.length: \(videoData.count)")
                        
                        _videos.append(videoData as NSData)
                        print("1: \(_videos.count)")
                        semaphore.signal()//当满足条件时，向队列发送信号
                    }
                })
                semaphore.wait()//阻塞并等待信号
            }
        }
        
        queue.async { //将任务代码块加入异步串行队列queue中
            print("2: end-for")
            let queue2 = DispatchQueue(label: "qForTWVideosUploadSquence")
            //发请求
            //            var flagForVideosUpload = 0
            for videoData in _videos.enumerated() {
                
                queue2.async {

                    let semaphore2 = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                    print( "total_bytes : \(videoData.element.length)")
                    //Step 1: INIT
                    let params = [
                        "command" : "INIT",
                        "media_type" : "video/mp4",
                        "total_bytes" : "\(videoData.element.length)"
//                        "status" : text!
                        ] as [String : Any]
                    
                    var urlError : NSError? = nil
                    // create request
                    let request = client.urlRequest(withMethod: "POST", url: self.uploadURL, parameters: params, error: &urlError)
                    if urlError != nil {
                        print("step 1: request create failed \(urlError)")
                        return
                    }
                    // send request
                    client.sendTwitterRequest(request, completion: { (response, data, error) in
                        if error != nil {
                            print("Step 1 INIT failed \(error)")
                            return
                        }
                        var mediaID = ""

                        do {
                             let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! NSDictionary
                            mediaID = dict["media_id_string"] as! String
                        }catch {
                            print("json error: \(error.localizedDescription)")

                        }
                        print("step 1: success \(mediaID)")
                        print("response: \(response)\ndata: \(data)\n")

                        
                        if mediaID.characters.count <= 0 {
                            print("mediaID <= 0")
                        } else {
                            print("go to step 2")
                            self.twitterMediaUploadAppend(client: client, data: videoData.element, mediaIDStr: mediaID, text: text)
                        }
                        
                    })
                }//END queue2
            }//END for
        }//END queue
    }//END sendTweetWithTextAndVideos
    
    ///MARK: VideoUpload Step 2: APPEND
    func twitterMediaUploadAppend(client: TWTRAPIClient, data: NSData, mediaIDStr: String, text: String?) {
        var index = 0
        //Step 2: APPEND
        let dataStr = data.base64EncodedString(options: .init(rawValue: 0))
//        data.base64EncodedData(options: .init(rawValue: 0))
        let params = [
            "command" : "APPEND",
            "media_id" : mediaIDStr,
            "media_data" : dataStr,
            "segment_index" : "\(index)"
//            "status" : text!
            ] as [String : Any]
        
        var urlError : NSError? = nil
        // create request
        let request = client.urlRequest(withMethod: "POST", url: uploadURL, parameters: params, error: &urlError)
        
        if urlError != nil {
            print("step 2: request create failed \(urlError)")
            return
        }
        
        client.sendTwitterRequest(request) { (reponse, data, error) in
            if error != nil {
                print("Step 2 APPEND failed \(error)")
                return
            }
//            index = index + 1
            print("step 2 APPEND success")
            print("response: \(reponse)\ndata: \(data)\n")
            self.twitterMediaUploadFinalize(client: client, mediaIDStr: mediaIDStr, text: text)
            
        }
    }//END twitterMediaUploadAppend
    
    ///MARK: VideoUpload Step 3: FINALIZE
    func twitterMediaUploadFinalize(client: TWTRAPIClient, mediaIDStr: String, text: String?) {
        //Step 3: FINALIZE
        let params = [
            "command" : "FINALIZE",
            "media_id" : mediaIDStr
//            "status" : text!
            ] as [String : Any]
        
        var urlError : NSError? = nil
        // create request
        let request = client.urlRequest(withMethod: "POST", url: uploadURL, parameters: params, error: &urlError)
        
        if urlError != nil {
            print("step 3: request create failed \(urlError)")
            return
        }
        
        client.sendTwitterRequest(request) { (reponse, data, error) in
            if error != nil {
                print("Step 3 FINALIZE failed \(reponse)\n\n\(data)\n\n\(error)")
                return
            }
            print("step 3 FINALIZE success")
            print("response: \(reponse)\ndata: \(data)\n")

            
            self.twitterStatusUpdate(client: client, mediaIDStr: mediaIDStr, text: text)
            
            
        }
    }
    
    ///MARK: VideoUpload Step 4: Tweet the uploaded video
    func twitterStatusUpdate(client: TWTRAPIClient, mediaIDStr: String, text: String?) {
        //Step 4: TWEET
        let params = [
            "status" : text!,
            "media_id" : mediaIDStr,
            "wrap_links" : "true"
            ] as [String : Any]
        
        var urlError : NSError? = nil
        // create request
        let request = client.urlRequest(withMethod: "POST", url: statusURL, parameters: params, error: &urlError)
        
        if urlError != nil {
            print("step 4: request create failed \(urlError)")
            return
        }
        
        client.sendTwitterRequest(request) { (reponse, data, error) in
            if error != nil {
                print("Step 4 TWEET failed \(error)")
                return
            }
            print("step 4 TWEET success")
            print("response: \(reponse)\ndata: \(data)\n")

        }
    }
    
   */
    
    
    
    
    
    
    


