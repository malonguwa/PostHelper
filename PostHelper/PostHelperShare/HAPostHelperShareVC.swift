//
//  HAPostHelperShareVC.swift
//  PostHelper
//
//  Created by LONG MA on 3/4/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
import UIKit
import Accounts
import Social

class HAPostHelperShareVC: UIViewController {
    @IBOutlet weak var postBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var snapShotView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    var sharedlink: NSURL?
    
    var snapshotView2 : UIView!
    
    var TWEnd = false
    var FBEnd = false
    
    
    func UIViewToUIImage() -> UIImage? {
//        let view = UIScreen.main.snapshotView(afterScreenUpdates: false)
        
        
        return nil
    }
    
    override func viewDidLoad() {
//        DispatchQueue.main.async {
            snapshotView2 = UIScreen.main.snapshotView(afterScreenUpdates: false)
        
//            snapshotView2.frame.size = CGSize(width: 50.0, height: 50.0 * 1.6)
//            self.snapShotView.addSubview(snapshotView2)
//            
//        }
        
        
        
        view.subviews[0].layer.cornerRadius = 9

//        selectPlatformsBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0,0, -selectPlatformsBtn.frame.size.width - 60)
//        selectPlatformsBtn.titleEdgeInsets = UIEdgeInsetsMake(0,  -200 , 0, 0)


        
        for item in extensionContext!.inputItems {
            let item = item as! NSExtensionItem
            DispatchQueue.main.async {
                self.textView.text = item.attributedContentText?.string
            }
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    let itemProvider = itemProvider as! NSItemProvider
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (object, error) -> Void in
                        
                        print("itemProvider.loadItem.public.url")
                        print("text: \(self.textView.text)")
                        if object != nil {
                            let nsurl = object as! NSURL
                            self.sharedlink = nsurl
//                            let nsurlStr = (object as! URL).absoluteString
//                            print(nsurlStr) //This is your URL
                        }
                    })
                    
                    itemProvider.loadPreviewImage(options: nil, completionHandler: { (object, error) in
//                        print(object)
                        
                        print("itemProvider.loadPreviewImage")
                        
                        if object != nil {
                            DispatchQueue.main.async {
                                if self.imageView.image == nil {
                                    print(object as! UIImage)
                                    self.imageView.image = (object as! UIImage)
                                    print("image != nil")
                                }
                            }
                        } else {
                            print("image == nil")
                        }
//                        else {
//                            print("image != nil ")
//                            self.snapshotView2.frame.size = CGSize(width: 50.0, height: 50.0 * 1.6)
//                            self.snapShotView.addSubview(self.snapshotView2)
//
//                        }
                    })
                }
            }
        }

    
    }
    
    
    
    @IBAction func cancelBtnClick(_ sender: Any) {
//        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        extensionContext?.cancelRequest(withError: NSError(domain: "NSUserCancelledError", code: NSUserCancelledError, userInfo: nil))
        

    }
    
    func postURLToFB(){
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
                
                self.FBEnd = true
                if self.FBEnd == true && self.TWEnd == true {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            })
            
            sessionDataTask.resume()
        }
    }
    
    
    func postURLToTW() {
        let accountStore = ACAccountStore()
        
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { (bool, error) in
            
            if bool == true {
                guard let accounts = accountStore.accounts(with: accountType) else {
                    print("accounts = nil")
                    return
                }
                
                if accounts.count > 0 {
                
                    //上传请求
                    
                    let url = URL(string: "https://api.twitter.com/1.1/statuses/update.json")
                    let params = [
                        "status" : self.textView.text + " " + (self.sharedlink?.absoluteString!)! as String
                        ] as [String : Any]
                    
                    let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, url: url, parameters: params)
                    request?.account = accounts[0] as! ACAccount
                    request?.perform(handler: { (data, reponse, error) in
                        print("data: \(String(describing: data))")
                        print("reponse: \(String(describing: reponse))")
                        print("error: \(String(describing: error))")
                        
                        self.TWEnd = true
                        if self.FBEnd == true && self.TWEnd == true {
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        }
  
                    })
                }
            } else {
                //不同意受权
            }
            
            
        }

    }
    
    @IBAction func postbtnClick(_ sender: UIButton) {
        
//        postURLToFB()
        postURLToTW()
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
//                        let message = "share link from ShareExtension"
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
