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
import FBSDKCoreKit

class HAFacebookManager: HASocialPlatformsBaseManager {
    
    var FacebookErrorStr : String?

    
    func facebookFilter() -> Bool{
        if platforms.count == 0 {
            return false
        } else if platforms.contains(.HAFacebook) == false {
            return false
            
        } else {
            return true
        }
    }

    
    // MARK: FB - Send Text Only
    func sendTextOnly(text : String!, completion: ((String?)->())?) {
        
        if facebookFilter() == false {
            completion!(nil)
            return
        }
    
       let fbsdRequest = FBSDKGraphRequest(graphPath: "/me/feed", parameters: ["message" : text], httpMethod: "POST")
       fbsdRequest?.setGraphErrorRecoveryDisabled(true)
       let _ = fbsdRequest?.start { (FBSDKGraphRequestConnection, data, Error) in
            if Error == nil {
                print("facebook post sucessfully")
                completion!(nil)
            } else {
                completion!("Facebook error : " + (Error?.localizedDescription)!)
            }
        
        }
    }
    
    
    
    // MARK: Send Photos and Text
    func sendGroupPhotos(images: [HAImage], text: String?, completion: ((String?)->())?) {
        if facebookFilter() == false {
            completion!(nil)
            return
        }
        
        var photoIDs = [String]()
        var dic = Dictionary<String,String>()

        let queue = DispatchQueue(label: "serialQForFBImageUpload")// 创建了一个串行队列
        
        for image in images.enumerated() {
            
                queue.async {//将任务代码块加入异步串行队列queue中
                    let semaphore = DispatchSemaphore(value: 0)//创建semaphore对象，用来调整信号量
                    
                    //判断image size
                    var imgData: NSData
                    let fileSizeInMB = Double(image.element.HAimageSize) * 0.000001024
                    if fileSizeInMB > 5.00 {
                        imgData = (image.element.HAimage?.resetSizeOfImageData(source_image: image.element.HAimage, maxSize: 5000))!
                    } else {
                        imgData = NSData(data: UIImageJPEGRepresentation(image.element.HAimage!, 0.6)!)
                    }
                    
                    if imgData.length <= 0 {
                        print("Facebook: -> image data error")
                    } else {
                        
                        let params = [
                            "source" : imgData,
                            "published" : false
                            ] as [String : Any]

                        let fbsdRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: params, httpMethod: "POST")
                        fbsdRequest?.setGraphErrorRecoveryDisabled(true)
                        
                        let _ = fbsdRequest?.start { (FBSDKGraphRequestConnection, data, error) in
                            if error == nil {
                                print("facebook image upload sucessfully")
                                HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: true ,currentPlatform: SocialPlatform.HAFacebook, isVideo: false)
                                
                                if data != nil {
                                    let responseDictionary = data as! Dictionary<String, Any>
                                    let photoID = responseDictionary["id"] as! String
                                    photoIDs.append(photoID)
                                    
                                }
                                
                            } else {
                                HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: false ,currentPlatform: SocialPlatform.HAFacebook, isVideo: false)
                                
//                                if image.offset == images.count - 1{
//                                    HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBImageFinalEND)
//                                }

                            }//End else
                            semaphore.signal()//当满足条件时，向队列发送信号

                        }//End request
                        semaphore.wait()//阻塞并等待信号
                    }
                }//END Queue
        }//END for
        
        queue.async {
            
            print("111111   \(photoIDs)")
            
            for photoID in photoIDs.enumerated(){
                let value = "{\"media_fbid\":\"\(photoID.element)\"}"
                dic.updateValue(value, forKey: "attached_media[\(photoID.offset)]")
                //                                print("\(dic)")
            }
            dic.updateValue(text!, forKey: "message")
            
            let publishPhotosRequest = FBSDKGraphRequest(graphPath: "me/feed", parameters: dic, httpMethod: "POST")
            publishPhotosRequest?.setGraphErrorRecoveryDisabled(true)
            
            let _ = publishPhotosRequest?.start(completionHandler: { (FBSDKGraphRequestConnection, data, error) in
                
                HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBImageFinalEND)
                
                if error == nil {
                    completion!(nil)
                    
                } else {
                    completion!(error?.localizedDescription)
                }
            })
        }//END Queue
    }

    
    
    // MARK: FB - Send Non-Resumable Video Only
    
    func FB_SendVideoOnly(avAssetsForSend: HAVideo, text: String?, completion: ((String?)->())?) {
        if facebookFilter() == false {
            completion!(nil)
            return
        }
        
        let videoData = NSData(contentsOf: avAssetsForSend.HAvideoURL!)
        if videoData == nil {
            completion!("video Data error")
            return
        }
        
        if Double((videoData?.length)!) * 0.000001024 > 1000.00 {//不能发往Facebook
            print("fileSize : \(Double((videoData?.length)!) * 0.000001024) MB")
            completion!("Video is too large for facebook")
            return
        }
        
        let videoParams = [
            "video.mov" : videoData!,
            "description" : text!,
            ] as [String : Any]
        
        let FBvideoUploadRequest = FBSDKGraphRequest(graphPath: "me/videos", parameters: videoParams, httpMethod: "POST")
        FBvideoUploadRequest?.setGraphErrorRecoveryDisabled(true)
        let _ = FBvideoUploadRequest?.start(completionHandler: { (FBSDKGraphRequestConnection, data, error) in
            if error == nil {
                print("facebook video upload success")
                HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: true ,currentPlatform: SocialPlatform.HAFacebook, isVideo: true)
//                HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBVideoFinalEND)
                completion!(nil)
                
            } else {
                print(error!)
                HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: false ,currentPlatform: SocialPlatform.HAFacebook, isVideo: true)
                completion!(error?.localizedDescription)
            }
            HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBVideoFinalEND)
        })
        
    }

    deinit {
        print("HAFacebookManager deinit")
    }
    
}
    
    
    
//    func sendGroupPhotosConnection(images: [HAImage], text: String?, completion: ((String?)->())?) {
//        
//        if facebookFilter() == false {
//            completion!(nil)
//            return
//        }
//        
//        let connection = GraphRequestConnection()
//        var photoIDs = [String]()
//        var dic = Dictionary<String,String>()
//        for image in images.enumerated() {
//            
//            let imageData = UIImageJPEGRepresentation(image.element.HAimage!, 0.6)
//            
//            if imageData == nil {
//                print("facebook: -> image data error")
//                return
//            }
//            
//            let params = [
//                "source" : imageData!,
//                "published" : false
//                ] as [String : Any]
//            
//            // self.HAFaceebook_albumID不使用了，因为FB会自动创建一个叫timeline的相册，改为me/photos
//            let request = GraphRequest(graphPath: "me/photos", parameters: params, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
//            
//            connection.add(request, batchParameters: ["name" : "\(image.offset)"], completion: { (HTTPURLResponse, GraphRequestResult) in
//                
////                print("request \(image.offset) + \(GraphRequestResult)")
//                switch GraphRequestResult {
//                case .failed(let error)://哪张相片上传失败了
//                    // Handle the result's error
//                    print(error)
//                    HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: false ,currentPlatform: SocialPlatform.HAFacebook, isVideo: false)
//                    
//                    if image.offset == images.count - 1{
//                        HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBImageFinalEND)
//                    }
//                    break
//                    
//                case .success(let graphResponse):
//                    print(" $$$$$$$$$$$+++++++++++ image.offset: \(image.offset) facebook .success ++++++++++")
//                    HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: true ,currentPlatform: SocialPlatform.HAFacebook, isVideo: false)
//                    
//
//                    if graphResponse.dictionaryValue != nil {
//                        let responseDictionary = graphResponse.dictionaryValue!
//                        
//                        let photoID = (responseDictionary["id"] as! String)
//                        photoIDs.append(photoID)
//                        
//                        if image.offset == images.count - 1{
//                            
//                            
//                            for photoID in photoIDs.enumerated(){
//                                let value = "{\"media_fbid\":\"\(photoID.element)\"}"
//                                dic.updateValue(value, forKey: "attached_media[\(photoID.offset)]")
//                                //                                print("\(dic)")
//                            }
//                            dic.updateValue(text!, forKey: "message")
//                            
//                            //                            dic.updateValue("{\"media_fbid\":\"156826574799880\"}", forKey: "attached_media[\(1)]")
//                            //                            print("dic: \(dic)")
//                            let publsishedPhotosRequest = GraphRequest(graphPath: "me/feed", parameters: dic, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
//                            publsishedPhotosRequest.start({ (HTTPURLResponse, GraphRequestResult) in
//                                switch GraphRequestResult {
//                                case .failed(let error):
//                                    print(error)
//                                    //FIXME: 这里加了新通知方法调用
//                                    HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBImageFinalEND)
//                                    completion!(error.localizedDescription)
//                                    
//                                    break
//                                case .success(let response):
//                                    
//                                    print("Final response - : \(response)")
//
//                                    //FIXME: 这里加了新通知方法调用
//                                    HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBImageFinalEND)
//                                    completion!(nil)
//                                }
//                                
//
//                            })
//                        }
//                    }//END if
//                }
//            })
//            
//        }//END for
//        
//        
//        /**
//         FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//         initWithGraphPath:@"/me/feed"
//         parameters:
//         
//         {
//         "attached_media[1]" : "{"media_fbid":"156814138134457"}",
//         "attached_media[2]" : "{"media_fbid":"156814141467790"}",
//         }
//         
//         
//         
//         HTTPMethod:@"POST"];
//         [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//         // Insert your code here
//         }];
//         */
//        
//        
//        connection.start()
//        connection.networkProgressHandler = { (bytesSent: Int64, totalBytesSent: Int64, totalExpectedBytes: Int64) -> () in
//            let totalBytesSent_double = Double.init(totalBytesSent)
//            let totalExpectedBytes_double = Double.init(totalExpectedBytes)
//            print("Image: totalBytesSent: \(totalBytesSent) ,totalExpectedBytes: \(totalExpectedBytes) ,\(String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100))%\n")
//        }
//    }//END func

    
    
    
    
    
//    func FB_SendVideoOnlyOld(avAssetsForSend: HAVideo, text: String?, completion: ((String?)->())?) {
//        
//        if facebookFilter() == false {
//            completion!(nil)
//            return
//        }
//        
//        
//        let videoData = NSData(contentsOf: avAssetsForSend.HAvideoURL!)
//        if videoData == nil {
//            completion!("video Data error")
//            return
//        }
//        
//        if Double((videoData?.length)!) * 0.000001024 > 1000.00 {//不能发往Facebook
//            print("fileSize : \(Double((videoData?.length)!) * 0.000001024) MB")
//            completion!("Video is too large for facebook")
//            return
//        }
//        
////        let connection = GraphRequestConnection()
//        
//        let videoParams = [
//            "video.mov" : videoData!,
//            "description" : text!,
//            ] as [String : Any]
//        
//        let videoSendRequest = GraphRequest(graphPath: "me/videos", parameters: videoParams, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
//
//        videoSendRequest.start {(HTTPURLResponse, GraphRequestResult) in
//            //            print(GraphRequestResult)
//            
//            switch GraphRequestResult {
//            case .failed(let error):
//                print(error)
//                //FIXME: 这里加了新通知方法调用
//                HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBVideoFinalEND)
//                HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: false ,currentPlatform: SocialPlatform.HAFacebook, isVideo: true)
//
//                completion!(error.localizedDescription)
//                break
//            case .success(_):
//                print("facebook video upload success")
//                //FIXME: 这里加了新通知方法调用
//                HASocialPlatformsBaseManager.sendFinalPostStatusNotification(isEnd: true, currentPlatform: SocialPlatform.HAFacebook, whoEnd: WhoUploadEnd.FBVideoFinalEND)
//                HASocialPlatformsBaseManager.sendPostStatusNotification(isSuccess: true ,currentPlatform: SocialPlatform.HAFacebook, isVideo: true)
//                completion!(nil)
//            }
//        }
    
        /*
        connection.add(videoSendRequest, batchParameters: nil, completion: {(HTTPURLResponse, GraphRequestResult) in
//            print(GraphRequestResult)
            
            switch GraphRequestResult {
            case .failed(let error):
                print(error)
                completion!(error.localizedDescription)
//                self.VideoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
                break
            case .success(_):
                print("facebook video upload success")
                completion!(nil)
//                    self.VideoUpdateUploadStatus!(100.00, uploadStatus.Success)
            }
        })
        
        connection.networkProgressHandler = { (bytesSent: Int64, totalBytesSent: Int64, totalExpectedBytes: Int64) -> () in
            let totalBytesSent_double = Double.init(totalBytesSent)
            let totalExpectedBytes_double = Double.init(totalExpectedBytes)
            print("Video: totalBytesSent: \(totalBytesSent) ,totalExpectedBytes: \(totalExpectedBytes) ,\(String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100))%\n")
        }

        connection.networkFailureHandler = { (error: Error) -> () in
//            self.VideoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
            print("\(error)")
        }

        
        connection.start()
        */
//    }

    
    
    
    
    

