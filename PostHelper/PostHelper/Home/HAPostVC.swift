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
    
    var avAssetsForSend = [DKAsset]()
    var postHelperAblumID : String?
    var facebookMgr = HAFacebookManager()

    
    // MARK: Enum
    enum WhichButton {
        case Pic
        case Video
    }
    
    
    
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
    
    // MARK: displayAVAsset
    func displayAVAssets(whichBtn : WhichButton) {
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
            
            //            self.avAssetsForSend = HnA_DKAssetArray
            self.avAssetsForSend.append(contentsOf: HnA_DKAssetArray)
            print(self.avAssetsForSend.count)
            
            guard let contentView = self.imageScrollView.subviews.first else {
                return
            }
            
            for asset in self.avAssetsForSend.enumerated() {
                if asset.element.isVideo == false { //image
                    asset.element.fetchImageWithSize(CGSize(width: 100, height: self.imageScrollView.frame.size.height), completeBlock: {(image, info) in
                        
                        let HAimageView = UIImageView(frame: CGRect(x: (asset.offset * 60) + 20 * asset.offset, y: 0, width: 60, height: 60))
                        HAimageView.image = image
                        contentView.addSubview(HAimageView)
                    })
                    
                } else { //video
                    asset.element.fetchAVAssetWithCompleteBlock({ (Asset, info) in
                        //                        print("~~~\(asset!)~~~\n")
                        //                        print(info!)
                        
                        let avurl = Asset as! AVURLAsset
                        
                        let serialQueue = DispatchQueue(label: "serialQForVideoImages")
                        serialQueue.sync {
                            
                            let videoImage = self.getVideoImage(videoURL: avurl.url)
                            
                            DispatchQueue.main.async(){
                                let HAimageView = UIImageView(frame: CGRect(x: (asset.offset * 60) + 20 * asset.offset, y: 0, width: 60, height: 60))
                                HAimageView.image = videoImage
                                contentView.addSubview(HAimageView)
                            }
                        }
                    })
                }
   
            }
            self.imageScrollView.isHidden = false
            self.textView.becomeFirstResponder()
        }
        
        if whichBtn == .Pic{
            imagePickerManager.addImage(naviController: self)
            
        } else if whichBtn == .Video{
            imagePickerManager.addVideo(naviController: self)

        }
        
    }
    
    
    
    // MARK: Pic Button click
    @IBAction func picBtnClick(_ sender: UIButton) {
        displayAVAssets(whichBtn : .Pic)
    }
 
    //MARK: Video Button click
    @IBAction func videoBtnClick(_ sender: UIButton) {
        displayAVAssets(whichBtn: .Video)
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
    func FB_SendImageOnly(avAssetsForSend : [DKAsset]!) {
//        guard let _avAssetsForSend = avAssetsForSend else {
//            print("image Array == nil")
//            return
//        }
        
        var _photos = [UIImage]()
        
        for asset in avAssetsForSend.enumerated() {
            asset.element.fetchOriginalImage(true, completeBlock: { (image, info) in
                
                if image != nil && asset.element.isVideo == false{
                    _photos.append(image!)
                }
            })
        }
        
        if _photos.count == 0 {
            
        } else {
//            postImagesToFB(images: _photos)
//            facebookMgr.sendGroupPhotos(images: _photos, albumID: postHelperAblumID)
            facebookMgr.findAlbum(images: _photos)
        }
    }
    
    
    
    // MARK: getFileSize
    func getSize(path: String!){
        let filePath = path
        var fileSize : UInt64
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath!)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            print(fileSize)
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    
    // MARK: FB - Send Non-Resumable Video Only
    func FB_SendVideoOnly(avAssetsForSend : [DKAsset]!) {
        let queue = DispatchQueue(label: "serialQForVideoUpload")// 创建了一个串行队列
        
        var _videos = [NSData]()
        let connection = GraphRequestConnection()
        
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
            //发请求
            
            for videoData in _videos {
                let videoParams = [
                    "video.mov" : videoData,
                    "description" : "This is test video"
//                    "unpublished_content_type" : DRAFT
                    ] as [String : Any]
                
                let videoSendRequest = GraphRequest(graphPath: "me/videos", parameters: videoParams, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                
                connection.add(videoSendRequest, batchEntryName: nil, completion: { (HTTPURLResponse, GraphRequestResult) in
                    print(GraphRequestResult)
                })
            }
            
            connection.start()
            
            let downloadProgressHandler = { (bytesSent: Int64, totalBytesSent: Int64, totalExpectedBytes: Int64) -> () in
                let totalBytesSent_double = Double.init(totalBytesSent)
                let totalExpectedBytes_double = Double.init(totalExpectedBytes)
                print("totalBytesSent: \(totalBytesSent) ,totalExpectedBytes: \(totalExpectedBytes) ,\(String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double))%\n")
            }
            
            let downloadFailureHandler = { (error: Error) -> () in
                print("\(error)")
            }
            
            connection.networkProgressHandler = downloadProgressHandler
            connection.networkFailureHandler = downloadFailureHandler
        }
    }
    
    // MARK: Send Button click
    @IBAction func sendBtnClick(_ sender: Any) {
        let flag = 0

        //--------------------------------------------send text
        if textView.text.characters.count != 0{
            FB_SendTextOnly(text: textView.text)
        }
        
        // -------------------------------------------send photo(s)
        if avAssetsForSend.count > 0 && flag == 0{//判断条件需要更改
            
            FB_SendImageOnly(avAssetsForSend: avAssetsForSend)
        }
        
        //-------------------------------------------send Video
        /// TODO: Send mutiple videos and share the same array(avAssetsForSend) with images
        if avAssetsForSend.count > 0 && flag == 1{
            print("start to send video(s)")

            FB_SendVideoOnly(avAssetsForSend: avAssetsForSend)
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

