//
//  HAPostHelperShareVC.swift
//  PostHelper
//
//  Created by LONG MA on 3/4/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
import UIKit

class HAPostHelperShareVC: UIViewController {
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var selectPlatformsBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var snapShotView: UIView!
    
    var sharedlink: NSURL?
    
    
    
    
    override func viewDidLoad() {
        DispatchQueue.main.async {
            let snapshotView2 = UIScreen.main.snapshotView(afterScreenUpdates: false)
            snapshotView2.frame.size = CGSize(width: 50.0, height: 50.0 * 1.6)
            self.snapShotView.addSubview(snapshotView2)
            
        }
        
        
        
        view.subviews[0].layer.cornerRadius = 9

        selectPlatformsBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0,0, -selectPlatformsBtn.frame.size.width - 60)
        selectPlatformsBtn.titleEdgeInsets = UIEdgeInsetsMake(0,  -200 , 0, 0)


        
        for item in extensionContext!.inputItems {
            let item = item as! NSExtensionItem
            DispatchQueue.main.async {
                self.textView.text = item.attributedContentText?.string
            }
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    let itemProvider = itemProvider as! NSItemProvider
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (object, error) -> Void in
                        if object != nil {
                            let nsurl = object as! NSURL
                            self.sharedlink = nsurl
                            let nsurlStr = (object as! URL).absoluteString
                            print(nsurlStr) //This is your URL
                        }
                    })
                }
            }
        }

    
    }
    
    
    func getInfoFromExtensionContext() {
        
    }
    
    
    
    @IBAction func cancelBtnClick(_ sender: Any) {
//        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        extensionContext?.cancelRequest(withError: NSError(domain: "NSUserCancelledError", code: NSUserCancelledError, userInfo: nil))
        

    }
    
    
    @IBAction func postbtnClick(_ sender: UIButton) {
        
        
        let keychainItem = KeychainPasswordItem.init(service: "PostHelperService", account: "FB_AccesssTokenForShare_Test", accessGroup: "group.com.HnA.PostHelperAPP")
        
        //获取
        var passW = ""
        do {
            try passW = keychainItem.readPassword()
            print("keychain成功\(passW)")
        } catch {
            print(error.localizedDescription)
        }
        
        if passW != "" {
            //发送请求
            var message = textView.text
            if message?.characters.count == 0 || message == nil{
                message = ""
            }
            //                        let link = "https://developers.facebook.com/docs/graph-api/using-graph-api/#fieldexpansion"
            
            let url : NSString = "https://graph.facebook.com/me/feed" as NSString
            
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
            
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            
//            http://stackoverflow.com/questions/42911395/share-extension-google-chrome-not-working/43250616#43250616
            let sharedURL = sharedlink?.absoluteString
            if sharedURL == nil {
                return
            }
            
            var request = URLRequest.init(url: searchURL as URL)
            request.httpMethod = "POST"
            request.httpBody = "message=\(message!)&access_token=\(passW)&link=\(sharedURL!)".data(using: String.Encoding.utf8)
            
            let session = URLSession.shared
            let sessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                print(data as Any)
                print(response as Any)
                print(error as Any)
                
                if error == nil {
                    let HTTPresponse = response as! HTTPURLResponse
                    if HTTPresponse.statusCode == 200 {
                        print("发送成功")
                    }
                    
                }
                
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                
                
            })
            
            sessionDataTask.resume()
        }

        
        
//        let inputItem = extensionContext?.inputItems.first as! NSExtensionItem
//        
//        let itemProvider = inputItem.attachments?.first as! NSItemProvider
//        
//        if itemProvider.hasItemConformingToTypeIdentifier("public.url") == true {
//            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (item, error) in
//                
//                if item is NSURL || item is URL {
//                    
//                    
//                    
//                    let sharedUrl = item as! NSURL
//                    
//                    let keychainItem = KeychainPasswordItem.init(service: "PostHelperService", account: "FB_AccesssTokenForShare_Test", accessGroup: "group.com.HnA.PostHelperAPP")
//                    
//                    //获取
//                    var passW = ""
//                    do {
//                        try passW = keychainItem.readPassword()
//                        print("keychain成功\(passW)")
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                    
//                    if passW != "" {
//                        //发送请求
//                        let message = "share link from ShareExtension"
//                        //                        let link = "https://developers.facebook.com/docs/graph-api/using-graph-api/#fieldexpansion"
//                        
//                        let url : NSString = "https://graph.facebook.com/me/feed" as NSString
//                        
//                        let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
//                        
//                        let searchURL : NSURL = NSURL(string: urlStr as String)!
//                        
//                        var request = URLRequest.init(url: searchURL as URL)
//                        request.httpMethod = "POST"
//                        request.httpBody = "message=sss&access_token=\(passW)&link=\(sharedUrl)".data(using: String.Encoding.utf8)
//                        
//                        let session = URLSession.shared
//                        let sessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
//                            print(data as Any)
//                            print(response as Any)
//                            print(error as Any)
//                            
//                            if error == nil {
//                                let HTTPresponse = response as! HTTPURLResponse
//                                if HTTPresponse.statusCode == 200 {
//                                    print("发送成功")
//                                }
//                                
//                            }
//                            
//                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//
//                            
//                        })
//                        
//                        sessionDataTask.resume()
//                    }
//                    
//                    
//                }
//                
//                
//            })
//        }
    }
    
    
    @IBAction func shareURLClick(_ sender: Any) {
        
        let inputItem = extensionContext?.inputItems.first as! NSExtensionItem
        
        let itemProvider = inputItem.attachments?.first as! NSItemProvider
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") == true {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (item, error) in
                
                if item is NSURL || item is URL {
                
                    
                    
                    let sharedUrl = item as! NSURL

                    let keychainItem = KeychainPasswordItem.init(service: "PostHelperService", account: "FB_AccesssTokenForShare_Test", accessGroup: "group.com.HnA.PostHelperAPP")
                    
                    //获取
                    var passW = ""
                    do {
                        try passW = keychainItem.readPassword()
                        print("keychain成功\(passW)")
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    if passW != "" {
                        //发送请求
                        let message = "share link from ShareExtension"
//                        let link = "https://developers.facebook.com/docs/graph-api/using-graph-api/#fieldexpansion"

                        let url : NSString = "https://graph.facebook.com/me/feed" as NSString

                        let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
                        
                        let searchURL : NSURL = NSURL(string: urlStr as String)!

                        var request = URLRequest.init(url: searchURL as URL)
                        request.httpMethod = "POST"
                        request.httpBody = "message=sss&access_token=\(passW)&link=\(sharedUrl)".data(using: String.Encoding.utf8)
                        
                        let session = URLSession.shared
                        let sessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                            print(data as Any)
                            print(response as Any)
                            print(error as Any)
                            
                            if error == nil {
                                let HTTPresponse = response as! HTTPURLResponse
                                if HTTPresponse.statusCode == 200 {
                                    print("发送成功")
                                }
                                
                            }
                            
                            

                        })
                        
                        sessionDataTask.resume()
                    }
                    

                }
                
//                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

            })
        }

    }
    
}
