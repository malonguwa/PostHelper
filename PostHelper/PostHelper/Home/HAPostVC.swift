//
//  HAPostVC.swift
//  PostHelper
//
//  Created by LONG MA on 17/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import DKImagePickerController
import AVFoundation

class HAPostVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentWidth: NSLayoutConstraint!
    @IBOutlet weak var imageScrollView: UIScrollView!
    var imagePickerManager : HAImagePickerManager = HAImagePickerManager()
//    var imageArrayForSend : [DKAsset]?
//    var videoArrayForSend : [DKAsset]?
    
    var avAssetsForSend : [DKAsset]?
    var postHelperAblumID : String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(HAPostVC.keyboardWillChange(notice :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }

    // MARK: Notification - UIKeyboardWillChangeFrame
    func keyboardWillChange(notice : Notification) {
        let value = notice.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let frame = value.cgRectValue
        let height = UIScreen.main.bounds.height
        let offsetY = height - frame.origin.y
        let duration = notice.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        toolBarBottomConstraint.constant = offsetY
        UIView.animate(withDuration: duration, animations:{ () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Pic Button click
    @IBAction func picBtnClick(_ sender: Any) {
        
        imagePickerManager.callBack = {
            self.imageScrollView.isHidden = true
            self.textView.becomeFirstResponder()
        }
        
        imagePickerManager.HnA_selectedAVAssets = { (HnA_DKAssetArray) in
            
            if HnA_DKAssetArray.count == 0 {
                self.imageScrollView.isHidden = false
                self.textView.becomeFirstResponder()
                return
            }
            
            self.avAssetsForSend = HnA_DKAssetArray
            guard let contentView = self.imageScrollView.subviews.first else {
                return
            }
            
            for asset in HnA_DKAssetArray.enumerated() {
                asset.element.fetchImageWithSize(CGSize(width: 100, height: self.imageScrollView.frame.size.height), completeBlock: {(image, info) in
                    let HAimageView = UIImageView(frame: CGRect(x: (asset.offset * 60) + 20 * asset.offset, y: 0, width: 60, height: 60))
                    
                    HAimageView.image = image
                    contentView.addSubview(HAimageView)
                })
            }
            
            self.imageScrollView.isHidden = false
            self.textView.becomeFirstResponder()
        }
        
        imagePickerManager.addImage(naviController: self)
    }
 
    //MARK: Video Button click
    @IBAction func videoBtnClick(_ sender: Any) {
        imagePickerManager.callBack = {
            self.imageScrollView.isHidden = true
            self.textView.becomeFirstResponder()
        }
        
        imagePickerManager.HnA_selectedAVAssets = { (HnA_DKAssetArray) in
            
            if HnA_DKAssetArray.count == 0 {
                self.imageScrollView.isHidden = false
                self.textView.becomeFirstResponder()
                return
            }
            
            self.avAssetsForSend = HnA_DKAssetArray
            
            guard let contentView = self.imageScrollView.subviews.first else {
                return
            }

            guard self.avAssetsForSend != nil else {
                return
            }
            self.avAssetsForSend?[0].fetchAVAssetWithCompleteBlock({ (Asset, info) in
                //                        print("~~~\(asset!)~~~\n")
                //                        print(info!)
                
                let avurl = Asset as! AVURLAsset
                
                let videoImage = self.getVideoImage(videoURL: avurl.url)
                
                
                DispatchQueue.main.async(){
                    let HAimageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                    
                    HAimageView.image = videoImage
                    contentView.addSubview(HAimageView)
                }
            })
            
            
            
            self.imageScrollView.isHidden = false
            self.textView.becomeFirstResponder()
        }
        
        imagePickerManager.addVideo(naviController: self)
    }
    
    
    // MARK: FB - Send Text Only
    func FB_SendTextOnly(text : String!) {
        GraphRequest(graphPath: "/me/feed", parameters:["message" : text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
            //text send completely
            print("text send completely + \(response)\n\(requestResult)\n")
            
            self.textView.text = ""
        }
    }
    // MARK: FB - Send Image Only
    func FB_SendImageOnly() {
        
    }
    
    // MARK: FB - Send Video Only

    // MARK: Send Button click
    @IBAction func sendBtnClick(_ sender: Any) {
        print("start to send")
        
        //--------------------------------------------send text
        if textView.text.characters.count != 0 {
            FB_SendTextOnly(text: textView.text)
        }
        
        // -------------------------------------------send photo(s)
        if avAssetsForSend != nil{
            guard let _avAssetsForSend = avAssetsForSend else {
                print("image Array == nil")
                return
            }
            
            var _photos = [UIImage]()

            //TODO:todo 1.发送多张图片循环优化
            for asset in _avAssetsForSend.enumerated() {
                asset.element.fetchOriginalImage(true, completeBlock: { (image, info) in
                    
                    if image != nil && asset.element.isVideo == false{
                        _photos.append(image!)
                   }
                })
            }
            
            if _photos.count == 0 {
                
            } else {
                postImagesToFB(images: _photos)
            }
    
        }
        
        //-------------------------------------------send Video
        let falg = 0
        if avAssetsForSend != nil && falg == 1{
            
            guard let _avAssetsForSend = avAssetsForSend else {
                print("image Array == nil")
                return
            }
            
            for asset in _avAssetsForSend.enumerated() {
                asset.element.fetchAVAssetWithCompleteBlock({ (Asset, info) in
                    //                        print("~~~\(asset!)~~~\n")
                    //                        print(info!)
                    
                    let avurl = Asset as! AVURLAsset
                    
                    let video = Video(url: avurl.url)
                    let content = VideoShareContent(video: video)
                    let sharer = GraphSharer(content: content)
                    sharer.failsOnInvalidData = true
                    sharer.completion = { result in
                        // video send completely
                        print("video send completely + \(result)\n")
//                        self.videoArrayForSend?.removeAll()
                        
                        
                    }
                    try! sharer.share()
                    
                    
                    //                    print("~~~\(avurl.url)~~~\n")
                })
            }
        }
    }
    
    
    //MARK: videoImage
    func getVideoImage(videoURL: URL!) -> UIImage {
        print(videoURL)

//        let url = NSURL(fileURLWithPath: videoURL)
        print("\(videoURL)")

        let asset = AVURLAsset(url: videoURL)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, 600)
        
        var actualTime = CMTimeMake(0, 0)
        let image = try!imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
     
        let thumb = UIImage(cgImage: image)
        
        return thumb
    }
    
    
    func postImagesToFB(images : [UIImage]) {
        
//        
//        var ablumID : String?
////        let text = "Text along with image"
//        let connectionForAlum = GraphRequestConnection()
//        let params = [
//            //                "message" : text,
//            "name" : "MyAlbum_PostHelper"
//            ] as [String : Any]

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
                            self.sendImagesToExistFBAlbum(images: images, albumID: dict["id"] as! String)
                            break
                            
                        }
                    }
                    
                    if albumIsFound == false {
                        //需要创建一个相册名字为MyAlbum_PostHelper，本地化保存该相册ID，再将照片存入
                        self.sendImagesToNewFBAlbum(images: images, albumName : "MyAlbum_PostHelper")
                        break
                    }
                }
            }
        })
    }
    
    // MARK: - sendImagesToExistFBAlbum
    private func sendImagesToExistFBAlbum(images: [UIImage], albumID: String!){
        print("exist - \(albumID)")
        

                    self.postHelperAblumID = albumID!
                    
                    let connection = GraphRequestConnection()
                    for image in images {
                        
                        let imageData = UIImageJPEGRepresentation(image, 90)
                        
                        //        let params = NSMutableDictionary.init(objects: [text, imageData!], forKeys: ["message" as NSCopying, "source" as NSCopying])
                        let params = [
                            //                "message" : text,
                            "source" : imageData!
                            ] as [String : Any]
                        
                        
                        let request = GraphRequest(graphPath: "\(self.postHelperAblumID!)/photos", parameters: params, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                        
                        connection.add(request, batchEntryName: nil, completion: { (response, result) in
//                            print(response!)
                            print("existAblums + \(result)")
                            
                        })
                        
                    }
                    
                    connection.start()

    }
    
    // MARK: - sendImagesToNewFBAlbum
    private func sendImagesToNewFBAlbum(images: [UIImage], albumName: String!){
//        let connectionForAlum = GraphRequestConnection()
        let params = [
            //                "message" : text,
            "name" : albumName!
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
                    let connection = GraphRequestConnection()
                    
                    let albumID = (responseDictionary["id"] as! String)
                    
                    //                    print("\(albumID)")
                    //                    print("dict : \(responseDictionary) \n")
                    self.postHelperAblumID = albumID
                    print(self.postHelperAblumID!)
                    for image in images {
                        
                        let imageData = UIImageJPEGRepresentation(image, 90)
                        
                        //        let params = NSMutableDictionary.init(objects: [text, imageData!], forKeys: ["message" as NSCopying, "source" as NSCopying])
                        let params = [
                            //                "message" : text,
                            "source" : imageData!
                            ] as [String : Any]
                        
                        
                        let request = GraphRequest(graphPath: "\(self.postHelperAblumID!)/photos", parameters: params, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                        
                        connection.add(request, batchEntryName: nil, completion: { (response, result) in
                            //                            print(response!)
                            print("existAblums + \(result)")
                            
                        })
                        
                    }
                    
                    connection.start()
                }
                
            }
        }

    }

    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        textView.resignFirstResponder()
    }
}

// MARK: UITextViewDelegate
extension HAPostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print("\(textView.text.characters.count)")
        if textView.text.lengthOfBytes(using: .utf8) > 0{
            sendBtn.isEnabled = true
            self.placeHolderLabel.alpha = 0
            
        } else {
            sendBtn.isEnabled = false
            self.placeHolderLabel.alpha = 1
        }
    }
}

