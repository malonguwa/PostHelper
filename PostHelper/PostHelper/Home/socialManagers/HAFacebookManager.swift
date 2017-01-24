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

class HAFacebookManager: NSObject {
    
    var HAFaceebook_albumID : String?
    var photoIDs = [String]()
    
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
    
    // MARK: Send Photos
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
        dic.updateValue(text!, forKey: "message")
        
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

            connection.add(request, batchParameters: ["name" : "\(image.offset)"], completion: { (HTTPURLResponse, GraphRequestResult) in
                print("request \(image.offset) + \(GraphRequestResult)")
                switch GraphRequestResult {
                case .failed(let error):
                    // Handle the result's error
                    print(error)
                    break
                    
                case .success(let graphResponse):
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
//                            dic.updateValue("{\"media_fbid\":\"156826574799880\"}", forKey: "attached_media[\(1)]")
//                            print("dic: \(dic)")
                            let publsishedPhotosRequest = GraphRequest(graphPath: "me/feed", parameters: dic, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                            publsishedPhotosRequest.start({ (HTTPURLResponse, GraphRequestResult) in
                                switch GraphRequestResult {
                                case .failed(let error):
                                    print(error)
                                    break
                                case .success(let response):
                                    self.photoIDs.removeAll()
                                    var array_platforms = [SocialPlatform]()
                                    array_platforms.append(contentsOf: sendToPlatforms)
                                    array_platforms.remove(at: 0)
                                    print("Final response - : \(response)")
                                    completion!(array_platforms)
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
        }

    }//END func

//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//    initWithGraphPath:@"/me/photos"
//    parameters:@{ @"url": @"http://www.w3schools.com/w3images/fjords.jpg",@"attached_media[0]": @"156791928136678",@"attached_media[1]": @"156791931470011",}
//    HTTPMethod:@"POST"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//    // Insert your code here
//    }];
    
}
