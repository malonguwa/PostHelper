//
//  HATwitterManager.swift
//  PostHelper
//
//  Created by LONG MA on 22/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit
import TwitterKit

class HATwitterManager: HASocialPlatformsBaseManager {
    let uploadURL = "https://upload.twitter.com/1.1/media/upload.json"
    let statusURL = "https://api.twitter.com/1.1/statuses/update.json"
//    var HAtimer : Timer?
//    var TWimageSendPercentage = 0.00
//    var TWvideoSendPercentage = 0.00
//    var count = 0
//    var offset = 0
//    var parts = 0

    
    func sendTweetWithTextOnly(text: String, sendToPlatforms: [SocialPlatform]!, completion: @escaping ([SocialPlatform], Error?)->()){
        for platform in sendToPlatforms {
            if platform == .HATwitter {
                break
            } else {
                completion(sendToPlatforms, nil)// sent to facebook Only, skip Twitter, error = nil
                return
            }
        }
        
        var twitterText = text
        
        if text.characters.count >= 140 {
            
            let index = twitterText.index((twitterText.startIndex), offsetBy: 139)
            twitterText = twitterText.substring(to: index)
        }
        
        let HATW_userID = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: HATW_userID!)
        var urlError : NSError? = nil
        let params = [
            "status" : twitterText,
            ] as [String : Any]
        let request = client.urlRequest(withMethod: "POST", url: "https://api.twitter.com/1.1/statuses/update.json", parameters: params, error: &urlError)
        
        if urlError !== nil {
            //            assert(false, "\(urlError)")
            //FIXME: 失败也要继续往下一个平台发
            
            print("something wrong in Twitter, continue to the next platform: \(platforms)")
            goToNextPlatform(sendToPlatforms: sendToPlatforms, error: urlError, completion: completion)
            return
        }
        client.sendTwitterRequest(request, completion: { (response, data, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else{
                print("\(response)\n\n\(data)\n\n\(error)")
                self.duplicateTextError = error
                self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: error, completion: completion)
                return
            }
            
            self.duplicateTextError = nil
            
            if httpResponse.statusCode == 200 {
                print("Tweet sucessfully")
                
                
                print("after send success in Twitter: \(platforms)")
                
                self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: nil, completion: completion)
            } else {
                print("\(response)\n\n\(data)\n\n\(error)")
                //FIXME: 失败也要继续往下一个平台发
                print("something wrong in Twitter, continue to the next platform: \(platforms)")
                self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: error, completion: completion)
            }
        })
        
        
    }

    
    /// MARK: TweetWithTextandImages
    func sendTweetWithTextandImages(images: [HAImage], text: String?, sendToPlatforms: [SocialPlatform]!, completion: @escaping ([SocialPlatform], Error?)->()) {
        
        for platform in sendToPlatforms {
            if platform == .HATwitter {
                break
            } else {
                completion(sendToPlatforms, nil)
                return
            }
        }
        
        let HATW_userID = Twitter.sharedInstance().sessionStore.session()?.userID
        var mediaIDs = [String]()
        let queue = DispatchQueue(label: "serialQForTWImageUpload")// 创建了一个串行队列
        let client = TWTRAPIClient(userID: HATW_userID!)
        
        for image in images.enumerated() {
            
            if image.offset <= 3 {
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
                        print("twitter: -> image data error")
                    } else {
                        client.uploadMedia(imgData as Data, contentType: "image/jpeg", completion: { (mediaID, error) in
                            if error != nil {
                                //FIXME: here to know which twitter image upload faliure
                                print("\(image.offset): error uploading media to Twitter \(error)")
                                                                /*
                                0: error uploading media to Twitter Optional(Error Domain=NSURLErrorDomain Code=-1001 "The request timed out." UserInfo={NSUnderlyingError=0x170446780 {Error Domain=kCFErrorDomainCFNetwork Code=-1001 "(null)" UserInfo={_kCFStreamErrorCodeKey=-2102, _kCFStreamErrorDomainKey=4}}, NSErrorFailingURLStringKey=https://upload.twitter.com/1.1/media/upload.json, NSErrorFailingURLKey=https://upload.twitter.com/1.1/media/upload.json, _kCFStreamErrorDomainKey=4, _kCFStreamErrorCodeKey=-2102, NSLocalizedDescription=The request timed out.})
                                 
                                 
                                 
                                 UserInfo={_kCFStreamErrorCodeKey=-2102, _kCFStreamErrorDomainKey=4}}, NSErrorFailingURLStringKey=https://upload.twitter.com/1.1/media/upload.json, NSErrorFailingURLKey=https://upload.twitter.com/1.1/media/upload.json, _kCFStreamErrorDomainKey=4, _kCFStreamErrorCodeKey=-2102, NSLocalizedDescription=The request timed out.}
                                 UserInfo={NSLocalizedFailureReason=Twitter API error : Status is a duplicate. (code 187), TWTRNetworkingStatusCode=403, NSErrorFailingURLKey=https://api.twitter.com/1.1/statuses/update.json, NSLocalizedDescription=Request failed: forbidden (403)}
                                */
                                
                            } else {
                                mediaIDs.append(mediaID!)
                                print(mediaIDs)
//                                if self.PhotoUpdateUploadStatus != nil {
//                                    self.TWimageSendPercentage = self.TWimageSendPercentage + 15.00
//                                    self.PhotoUpdateUploadStatus!(CGFloat(self.TWimageSendPercentage), uploadStatus.Uploading)
//                                }
                            }
                            semaphore.signal()//当满足条件时，向队列发送信号
                        })
                        semaphore.wait()//阻塞并等待信号
                    }
                }//END Queue
            }//END if
            else {
                print("image.offset == \(image.offset)") //5
                break
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
                //                assert(false, "\(urlError)")
                //FIXME: 失败也要继续往下一个平台发
                print("136 line - urlError != nil")
                self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: urlError, completion: completion)
                
                return
            }
            client.sendTwitterRequest(request, completion: { (response, data, error) in
                
                guard let httpResponse = response as? HTTPURLResponse else{
                    print("144 line - response == nil")
                    print("144 line - \(response)\n\n\(data)\n\n\(error)")
                    //FIXME: 失败也要继续往下一个平台发
                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: error, completion: completion)
                    
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("154 line - Tweet sucessfully")
                    print("154 line - httpResponse.statusCode == 200")
//                    if self.PhotoUpdateUploadStatus != nil {
//                        self.PhotoUpdateUploadStatus!(100.00, uploadStatus.Success)
//                        self.TWimageSendPercentage = 0.00
//                    }
                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: nil, completion: completion)
                    
                } else {
                    //FIXME: 失败也要继续往下一个平台发
                    print("159 line - else")
                    print("159 line - \(response)\n\n\(data)\n\n\(error)")
//                    self.PhotoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
                    
                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: error, completion: completion)
                    
                }
            })
            
        }
        
    }

    

    /// MARK: TweetWithTextandVideo
    func sendTweetWithTextandVideo(video: HAVideo, text: String?, sendToPlatforms: [SocialPlatform]!, completion: @escaping ([SocialPlatform], Error?)->()) {

        for platform in sendToPlatforms {
            if platform == .HATwitter {
                break
            } else {// has to be HAFacebook
                completion(sendToPlatforms, nil)
                return
            }
        }
        
        
        let accountStore = ACAccountStore()

        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { [weak self] (bool, error) in
            if bool == true {
                guard let accounts = accountStore.accounts(with: accountType) else {
                    print("accounts = nil")
                    completion(sendToPlatforms, error)
                    return
                }
                
                if accounts.count > 0 {
                    // step 0: 将DKAsset对象中的video.url转化成NSData
                    let videoData = NSData(contentsOf: video.HAvideoURL!)
                    if videoData == nil{
                        print("data == nil")
                    }
                    
                    if Double((videoData?.length)!) * 0.000001024 > 500.00 {//不能发往Twitter
                        print("fileSize : \(Double((videoData?.length)!) * 0.000001024) MB")
                        
                    } else {//符合要求开始上传
                        SocialVideoHelper.uploadTwitterVideo(videoData as! Data, comment: text, account: accounts[0] as! ACAccount, withCompletion: { [weak self] (success, errorMessageStr) in
                            if success == true {
                                print("Twitter video upload success")
                                //                                        self.HAtimer?.invalidate()
                                //                                        self.HAtimer = nil
//                                self?.TWvideoSendPercentage = 0.00
                                
                                print("after send success in Twitter: \(platforms)")
                                
//                                self?.HAtimer?.invalidate()
//                                self?.HAtimer = nil
                                //FIXME: here
//                                if self?.VideoUpdateUploadStatus != nil {
//                                    self?.VideoUpdateUploadStatus!(CGFloat(100.00), uploadStatus.Success)
//                                    
//                                }
                                
                                self?.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: nil, completion: completion)
                                
                                
                            } else {
                                print("372 - \(errorMessageStr)")
                                //                                        self.HAtimer?.invalidate()
                                //                                        self.HAtimer = nil
                                //FIXME: 失败也要继续往下一个平台发
                                
//                                self?.HAtimer?.invalidate()
//                                self?.HAtimer = nil
//                                self?.VideoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
                               let error = NSError.init(domain: "", code: 0, userInfo: ["NSLocalizedDescriptionKey" : errorMessageStr!])
                                
                                self?.goToNextPlatform(sendToPlatforms: sendToPlatforms, error: error, completion: completion)
                            }

                        })
                    }
                } else {
                    print("\(accounts)")
                }
            } else {//不受权
                //FIXME: 提示用户自己去授权
            }
            
        }
    }

    
    
    
    
    
    
    
    
    
}


