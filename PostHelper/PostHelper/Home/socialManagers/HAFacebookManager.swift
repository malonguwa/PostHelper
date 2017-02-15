//
//  HAFacebookManager.swift
//  PostHelper
//
//  Created by LONG MA on 14/12/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import DKImagePickerController
import AVFoundation

class HAFacebookManager: HASocialPlatformsBaseManager {
    
    var HAFaceebook_albumID : String?
    var photoIDs = [String]()
    var FBimageSendPercentage : String?
    var FBvideoSendPercentage : String?

    /**
    // MARK: Find Album
    func findAlbum(images : [UIImage]) {
        let paramsForAblumExist = [
            "fields" : "id, name"
            ] as [String : Any]
        
        //fetch all exist albums as [Dict]
        GraphRequest(graphPath: "me/albums", parameters: paramsForAblumExist, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.GET, apiVersion: GraphAPIVersion.defaultVersion).start({ (HTTPResponse, GraphRequestResult) in
            
            switch GraphRequestResult {
            case .failed(let error):
                print("postImagesToFB() + \(error)")
                break;
                
            case .success(let graphResponse):
                if graphResponse.dictionaryValue != nil {
                    print("Ablum list + \(graphResponse.dictionaryValue!)")
                    let responseDictionary = graphResponse.dictionaryValue!
                    
                    let array = responseDictionary["data"] as! [NSDictionary]
                    
                    var albumIsFound = false
                    for dict in array {
                        
                        if dict["name"] as! String == "MyAlbum_PostHelper"{
                            //已经有一个相册名字叫MyAlbum_PostHelper，无需创建，拿到该相册ID，直接将照片存入
                            print(dict["name"]!)
                            albumIsFound = true
                            self.sendGroupPhotos(images: images, albumID: dict["id"] as! String)
                            break
                            
                        }
                    }
                    
                    if albumIsFound == false {
                        //向FB服务器发送POST请求创建名为"MyAlbum_PostHelper"的相册
                        let params = [
                            //                "message" : text,
                            "name" : "MyAlbum_PostHelper"
                            ] as [String : Any]
                        
                        let requestCreateAlbum = GraphRequest(graphPath: "me/albums", parameters: params, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                        
                        requestCreateAlbum.start { (response, result) in
                            print("1-newAlbum + \(result)")
                            switch result {
                            case .failed(let error):
                                // Handle the result's error
                                print(error)
                                break
                                
                            case .success(let graphResponse):
                                if graphResponse.dictionaryValue != nil {
                                    // Do something with your responseDictionary
                                    let responseDictionary = graphResponse.dictionaryValue!
                                    //取出刚刚创建好的 "MyAlbum_PostHelper"的AlbumID
                                    let albumID = (responseDictionary["id"] as! String)
                                    self.sendGroupPhotos(images: images, albumID: albumID)
                                }
                                
                            }
                        }
                        
                        break
                    }
                }
            }
        })

    }
*/
    // MARK: FB - Send Text Only
    func sendTextOnly(text : String!, sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform])->())?) {
        
        if sendToPlatforms.count == 0 {
            completion!(sendToPlatforms)
            return
        }
        
        for platform in sendToPlatforms {
            if platform == .HAFacebook {
                break
            } else {
                print("FB - Send Text Only else \(platforms)")
                completion!(sendToPlatforms)
                return
            }
        }

        
        GraphRequest(graphPath: "/me/feed", parameters:["message" : text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
            //text send completely
            print("text send completely + \(response)\n\(requestResult)\n")
            self.goToNextPlatform(sendToPlatforms: sendToPlatforms, completion: completion)
        }
    }
    
    // MARK: Send Photos and Text
    func sendGroupPhotos(images: [UIImage], text: String?, sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform])->())?) {
        print("HAFacebook : \(sendToPlatforms)")
        
        if sendToPlatforms.count == 0 {
            completion!(sendToPlatforms)
            return
        }
        
        for platform in sendToPlatforms {
            print("in for")
            if platform == .HAFacebook {
                break
            } else {
                print("Facebook completion start")
                completion!(sendToPlatforms)
                return
            }
        }
//        print("should not see here")

        
        let connection = GraphRequestConnection()
        
        var dic = Dictionary<String,String>()
        for image in images.enumerated() {
            
            let imageData = UIImageJPEGRepresentation(image.element, 0.6)

            if imageData == nil {
                print("facebook: -> image data error")
                return
            }
            
            let params = [
                    "source" : imageData!,
                    "published" : false
                    ] as [String : Any]
            
            // self.HAFaceebook_albumID不使用了，因为FB会自动创建一个叫timeline的相册，改为me/photos
            let request = GraphRequest(graphPath: "me/photos", parameters: params, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)

//            request.start(<#T##completion: (HTTPURLResponse?, GraphRequestResult<GraphRequest>) -> Void?##(HTTPURLResponse?, GraphRequestResult<GraphRequest>) -> Void?##(HTTPURLResponse?, GraphRequestResult<GraphRequest>) -> Void#>)
            connection.add(request, batchParameters: ["name" : "\(image.offset)"], completion: { (HTTPURLResponse, GraphRequestResult) in
                print("request \(image.offset) + \(GraphRequestResult)")
                switch GraphRequestResult {
                case .failed(let error):
                    // Handle the result's error
                    print(error)
                    break
                    
                case .success(let graphResponse):
                    print(" $$$$$$$$$$$+++++++++++ image.offset: \(image.offset) facebook .success ++++++++++")
                    if graphResponse.dictionaryValue != nil {
                        let responseDictionary = graphResponse.dictionaryValue!
                        
                        let photoID = (responseDictionary["id"] as! String)
                        self.photoIDs.append(photoID)
                        print(self.photoIDs)
                        
                        if image.offset == images.count - 1{


                            for photoID in self.photoIDs.enumerated(){
                                let value = "{\"media_fbid\":\"\(photoID.element)\"}"
                                dic.updateValue(value, forKey: "attached_media[\(photoID.offset)]")
//                                print("\(dic)")
                            }
                            dic.updateValue(text!, forKey: "message")

//                            dic.updateValue("{\"media_fbid\":\"156826574799880\"}", forKey: "attached_media[\(1)]")
//                            print("dic: \(dic)")
                            let publsishedPhotosRequest = GraphRequest(graphPath: "me/feed", parameters: dic, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                            publsishedPhotosRequest.start({ (HTTPURLResponse, GraphRequestResult) in
                                switch GraphRequestResult {
                                case .failed(let error):
                                    print(error)
                                    if self.PhotoUpdateUploadStatus != nil {
                                        self.PhotoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
                                    }

                                    //FIXME: 失败也要继续往下一个平台发
                                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, completion: completion)

                                    break
                                case .success(let response):
                                    self.photoIDs.removeAll()

                                    print("Final response - : \(response)")

                                    if self.PhotoUpdateUploadStatus != nil {
                                        self.PhotoUpdateUploadStatus!(100.00, uploadStatus.Success)
                                    }

                                    //FIXME: 成功也要继续往下一个平台发
                                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, completion: completion)

                                }
                            })
                        }
                    }
                }
            })
            
        }//END for
        
        
        /**
         FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
         initWithGraphPath:@"/me/feed"
         parameters:
         
         {
         "attached_media[1]" : "{"media_fbid":"156814138134457"}",
         "attached_media[2]" : "{"media_fbid":"156814141467790"}",
         }
         
         
         
         HTTPMethod:@"POST"];
         [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         // Insert your code here
         }];
 */
        
        
        connection.start()
        connection.networkProgressHandler = { (bytesSent: Int64, totalBytesSent: Int64, totalExpectedBytes: Int64) -> () in
            let totalBytesSent_double = Double.init(totalBytesSent)
            let totalExpectedBytes_double = Double.init(totalExpectedBytes)
            print("Image: totalBytesSent: \(totalBytesSent) ,totalExpectedBytes: \(totalExpectedBytes) ,\(String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100))%\n")
            self.FBimageSendPercentage = String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100)
            if self.PhotoUpdateUploadStatus != nil {
                self.PhotoUpdateUploadStatus!(CGFloat(Double(self.FBimageSendPercentage!)!), uploadStatus.Uploading)
            }
        }
    }//END func

    
    
    // MARK: FB - Send Non-Resumable Video Only
    func FB_SendVideoOnly(avAssetsForSend : [DKAsset]!, text: String?, sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform])->())?) {
        
        if sendToPlatforms.count == 0 {
            completion!(sendToPlatforms)
            return
        }
        
        for platform in sendToPlatforms {
            print("in for")
            if platform == .HAFacebook {
                break
            } else {
                print("Facebook completion start")
                completion!(sendToPlatforms)
                return
            }
        }

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
        
        queue.async { //将任务代码块加入异步串行队列queue中
            print("2: end-for")
            let queue2 = DispatchQueue(label: "qForVideosUploadSquence")
            //发请求
            //            var flagForVideosUpload = 0
            for videoData in _videos.enumerated() {
                
                queue2.async {
                    let semaphore2 = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                    
                    let connection = GraphRequestConnection()
                    let downloadProgressHandler = { (bytesSent: Int64, totalBytesSent: Int64, totalExpectedBytes: Int64) -> () in
                        let totalBytesSent_double = Double.init(totalBytesSent)
                        let totalExpectedBytes_double = Double.init(totalExpectedBytes)
                        print("Video: totalBytesSent: \(totalBytesSent) ,totalExpectedBytes: \(totalExpectedBytes) ,\(String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100))%\n")
                        self.FBvideoSendPercentage = String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100)
                        print("\(CGFloat(Double(self.FBvideoSendPercentage!)!))")
                        if self.VideoUpdateUploadStatus != nil {
                            self.VideoUpdateUploadStatus!(CGFloat(Double(self.FBvideoSendPercentage!)!) / CGFloat(_videos.count) + (100.00 / CGFloat(_videos.count) * CGFloat(videoData.offset)), uploadStatus.Uploading)
                        }
                    }
                    
                    let downloadFailureHandler = { (error: Error) -> () in
                        self.VideoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
                        print("\(error)")
                    }
                    
                    let videoParams = [
                        "video.mov" : videoData.element,
                        "description" : text!,
                        ] as [String : Any]
                    
                    let videoSendRequest = GraphRequest(graphPath: "me/videos", parameters: videoParams, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                    
                    connection.add(videoSendRequest, batchParameters: ["omit_response_on_success" : false], completion: {(HTTPURLResponse, GraphRequestResult) in
                        print(GraphRequestResult)
                        
                        switch GraphRequestResult {
                        case .failed(let error):
                            print(error)
                            self.VideoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
                            break
                        case .success(let response):
                            if videoData.offset == _videos.count - 1 {
                                var array_platforms = [SocialPlatform]()
                                array_platforms.append(contentsOf: sendToPlatforms)
                                array_platforms.remove(at: 0)
                                print("Final response - : \(response)")
                                completion!(array_platforms)
                                self.VideoUpdateUploadStatus!(100.00, uploadStatus.Success)
                            }
                            
                        }
                        semaphore2.signal()
                    })
                    connection.networkProgressHandler = downloadProgressHandler
                    connection.networkFailureHandler = downloadFailureHandler
                    
                    connection.start()
                    
                    semaphore2.wait()
                }
                
            }//end for
            
            
            
            
        }
    }
    
    // MARK: FB - Send Resumable Video Only
    func FB_SendResumableVideoOnly(avAssetsForSend : [DKAsset]!, text: String?, sendToPlatforms: [SocialPlatform]!, completion: (([SocialPlatform])->())?) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        guard let accounts = accountStore.accounts(with: accountType) else {
            print("account = nil")
            return
        }
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

        queue.async(flags: .barrier) {
            for videoData in _videos {
                
                SocialVideoHelper.uploadFacebookVideo(videoData as Data!, comment: text, account: accounts[0] as! ACAccount, withCompletion: { (success, errorMessage) in
                    if success == true {
                        print("Twitter video upload success")
                        var array_platforms = [SocialPlatform]()
                        array_platforms.append(contentsOf: sendToPlatforms)
                        array_platforms.remove(at: 0)
                        print("array_platforms: \(array_platforms)")
                        
                        print("after send success in Twitter: \(platforms)")
                        
                        completion!(array_platforms)
                        
                    } else {
                        print(errorMessage!)
                    }
                })
            }//end for
        }
    }

    
    
    
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//    initWithGraphPath:@"/me/photos"
//    parameters:@{ @"url": @"http://www.w3schools.com/w3images/fjords.jpg",@"attached_media[0]": @"156791928136678",@"attached_media[1]": @"156791931470011",}
//    HTTPMethod:@"POST"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//    // Insert your code here
//    }];
    
}
