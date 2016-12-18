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
//                            self.sendImagesToExistFBAlbum(images: images, albumID: dict["id"] as! String)
                            self.sendGroupPhotos(images: images, albumID: dict["id"] as! String)
                            break
                            
                        }
                    }
                    
                    if albumIsFound == false {
                        //需要创建一个相册名字为MyAlbum_PostHelper，本地化保存该相册ID，再将照片存入
//                        self.sendImagesToNewFBAlbum(images: images, albumName : "MyAlbum_PostHelper")
                        break
                    }
                }
            }
        })

    }
    
    func sendGroupPhotos(images: [UIImage], albumID: String!) {
        
        self.HAFaceebook_albumID = albumID
        
        let connection = GraphRequestConnection()
        
        for image in images.enumerated() {
            
            let imageData = UIImageJPEGRepresentation(image.element, 90)
            
            let params = [
                //                "message" : text,
                "source" : imageData!,
                "published" : true
                ] as [String : Any]
            
            
            let request = GraphRequest(graphPath: "\(self.HAFaceebook_albumID!)/photos", parameters: params, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)

            
            if image.offset == 0 {
                
                connection.add(request, batchParameters: ["name" : "\(image.offset)"], completion: { (HTTPURLResponse, GraphRequestResult) in
                    print("request 0 + \(GraphRequestResult)")
                    switch GraphRequestResult {
                    case .failed(let error):
                        // Handle the result's error
                        print(error)
                        break
                        
                    case .success(let graphResponse):
                        if graphResponse.dictionaryValue != nil {
                            // Do something with your responseDictionary
                            let responseDictionary = graphResponse.dictionaryValue!
                            
                            let photoID = (responseDictionary["id"] as! String)
                            self.photoIDs.append(photoID)
                            print(self.photoIDs)
                        }
                    }
                })
            } else {
                
                connection.add(request, batchParameters: ["name" : "\(image.offset)", "depends_on" : "\(image.offset-1)", "omit_response_on_success" : false], completion: { (HTTPURLResponse, GraphRequestResult) in
                    print("request \(image.offset) + \(GraphRequestResult)")
                    switch GraphRequestResult {
                    case .failed(let error):
                        // Handle the result's error
                        print(error)
                        break
                        
                    case .success(let graphResponse):
                        if graphResponse.dictionaryValue != nil {
                            // Do something with your responseDictionary
                            let responseDictionary = graphResponse.dictionaryValue!
                            
                            let photoID = (responseDictionary["id"] as! String)
                            self.photoIDs.append(photoID)
                            print(self.photoIDs)
                            
//                            print(graphResponse.dictionaryValue! as [String : Any])


                        }
                    }

                })

                
            }
            
            
            
            
            
        }
        
        connection.start()

    }
    
    
    
}
