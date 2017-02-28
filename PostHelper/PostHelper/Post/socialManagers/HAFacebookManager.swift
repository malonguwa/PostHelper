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
            //            completion(nil)
            return false
        } else if platforms.contains(.HAFacebook) == false {
            //            completion(nil)
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
//        if platforms.count == 0 {
//            completion!(nil)
//            return
//        }
//        
//        if platforms.contains(.HAFacebook) == false {
//            completion!(nil)
//            return
//
//        }
    
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
//        if sendToPlatforms.count == 0 {
//            completion!(sendToPlatforms)
//            return
//        }
//        
//        for platform in sendToPlatforms {
//            print("in for")
//            if platform == .HAFacebook {
//                break
//            } else {
//                print("Facebook completion start")
//                completion!(sendToPlatforms)
//                return
//            }
//        }
        //        print("should not see here")
        
        
        let connection = GraphRequestConnection()
        var photoIDs = [String]()
        var dic = Dictionary<String,String>()
        for image in images.enumerated() {
            
            let imageData = UIImageJPEGRepresentation(image.element.HAimage!, 0.8)
            
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
            
            
            connection.add(request, batchParameters: ["name" : "\(image.offset)"], completion: { (HTTPURLResponse, GraphRequestResult) in
                

                print("request \(image.offset) + \(GraphRequestResult)")
                switch GraphRequestResult {
                case .failed(let error)://哪张相片上传失败了
                    // Handle the result's error
                    print(error)
                    break
                    
                case .success(let graphResponse):
                    print(" $$$$$$$$$$$+++++++++++ image.offset: \(image.offset) facebook .success ++++++++++")
                    if graphResponse.dictionaryValue != nil {
                        let responseDictionary = graphResponse.dictionaryValue!
                        
                        let photoID = (responseDictionary["id"] as! String)
                        photoIDs.append(photoID)
//                        print(photoIDs)
                        
                        if image.offset == images.count - 1{
                            
                            
                            for photoID in photoIDs.enumerated(){
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
//                                    if self.PhotoUpdateUploadStatus != nil {
//                                        self.PhotoUpdateUploadStatus!(CGFloat(0.00), uploadStatus.Failure)
//                                    }
                                    
                                    //FIXME: 失败也要继续往下一个平台发
//                                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, completion: completion)
                                    completion!(error.localizedDescription)
                                    
                                    break
                                case .success(let response):
                                    
                                    print("Final response - : \(response)")
                                    
//                                    if self.PhotoUpdateUploadStatus != nil {
//                                        self.PhotoUpdateUploadStatus!(100.00, uploadStatus.Success)
//                                    }
                                    
                                    //FIXME: 成功也要继续往下一个平台发
//                                    self.goToNextPlatform(sendToPlatforms: sendToPlatforms, completion: completion)
                                    completion!(nil)
                                }
                                
//                                self.photoIDs.removeAll()

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
//            self.FBimageSendPercentage = String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100)
//            if self.PhotoUpdateUploadStatus != nil {
//                self.PhotoUpdateUploadStatus!(CGFloat(Double(self.FBimageSendPercentage!)!), uploadStatus.Uploading)
//            }
        }
    }//END func

    
    deinit {
        print("HAFacebookManager deinit")
    }
    
    
    
    
}
