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
    @IBOutlet weak var contentView: UIView!
    var imagePickerManager : HAImagePickerManager = HAImagePickerManager()
    var avAssetsForSend = [DKAsset]()
    var avAssetsForDisplay = [UIImage]()
    var postHelperAblumID : String?
    var facebookMgr = HAFacebookManager()
    var twitterMgr = HATwitterManager()
    fileprivate lazy var isPresent : Bool = false


//    var mutiPlatform
    
    //    var imageArrayForSend : [DKAsset]?
    //    var videoArrayForSend : [DKAsset]?
    
    // MARK: Enum for image or video picker controller
    enum WhichButton {
        case Pic
        case Video
    }
    
    // MARK: System functions
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(HAPostVC.keyboardWillChange(notice :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        if hasAuthToTwitter == false && hasAuthToFacebook == false {
            sendBtn.isEnabled = false
            //TODO HUD提醒用户至少选择一个平台
        }
        
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
    
    
    // MARK: Button target - Pic/Video Button is clicked
    func displayAVAssets(whichBtn : WhichButton) {
        imagePickerManager.callBack = {
            if self.avAssetsForDisplay.count == 0 {
                self.imageScrollView.isHidden = true
            } else {
                self.imageScrollView.isHidden = false
            }
            self.textView.becomeFirstResponder()
        }

        
        imagePickerManager.HnA_selectedAVAssets = { (HnA_DKAssetArray) in

            if HnA_DKAssetArray.count == 0 {
                self.imageScrollView.isHidden = false
                self.textView.becomeFirstResponder()
                return
            }
            
            self.avAssetsForDisplay.removeAll()
            self.avAssetsForSend.removeAll()
            
            self.avAssetsForSend.append(contentsOf: HnA_DKAssetArray)
            print(self.avAssetsForSend.count)
            
            let serialQueue2 = DispatchQueue(label: "serialQ2ForAVSelection")
            
            for asset in HnA_DKAssetArray.enumerated() {
                serialQueue2.async {
                    if asset.element.isVideo == false { //image
                        asset.element.fetchOriginalImage(true, completeBlock: { (image, info) in
                            let resizedImg = UIImage.HA_resizeImage(image: image)
                            self.addImageAndDeleteBtn(image: resizedImg, offset: self.avAssetsForDisplay.count)
                            self.avAssetsForDisplay.append(resizedImg)
                        })
                    } else { //video
                        asset.element.fetchAVAsset(true, options: nil, completeBlock: { (Asset, info) in
                            let avurl = Asset as! AVURLAsset
                            
                            //TODO判断是否压缩后的视频是否满足条件： 视频格式和尺寸
                            
                            
                            let videoImage = self.getVideoImage(videoURL: avurl.url)
                            let resizedImg = UIImage.HA_resizeImage(image: videoImage)
                            self.addImageAndDeleteBtn(image: resizedImg, offset: self.avAssetsForDisplay.count)
                            self.avAssetsForDisplay.append(resizedImg)
                        })
                    }
                }
            }
            self.imageScrollView.isHidden = false
            self.textView.becomeFirstResponder()
        }//end block
        

        if whichBtn == .Pic{
            imagePickerManager.addImage(naviController: self)
        } else if whichBtn == .Video{
            imagePickerManager.addVideo(naviController: self)
        }
    }
    
    // MARK: @synchronized - Lock
    public func synchronized(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    
    
    // MARK: Button - addImageAndDeleteBtn
    func addImageAndDeleteBtn(image: UIImage, offset: Int) {
        print("addImageAndDeleteBtn : \(offset)")
        print("\(image.size)")
        let HAimageView = UIImageView(image: image)
//        HAimageView.frame = CGRect(x: (offset * 100) + 20 * offset, y: 0, width: Int(image.size.width), height: Int(image.size.height))
        HAimageView.frame = CGRect(x: (offset * 100) + 20 * offset, y: 0, width: 100, height: 100)
        HAimageView.backgroundColor = UIColor.lightGray
        HAimageView.isUserInteractionEnabled = true
        HAimageView.contentMode = UIViewContentMode.scaleAspectFit
        let deleteBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        deleteBtn.backgroundColor = UIColor.black
        deleteBtn.tag = offset
        
        DispatchQueue.main.async(){
            self.contentView.addSubview(HAimageView)
            HAimageView.addSubview(deleteBtn)
            deleteBtn.addTarget(self, action: #selector(HAPostVC.deleteImageInScrollView(_:)), for: UIControlEvents.touchUpInside)
            self.scrollViewContentWidth.constant = CGFloat((self.avAssetsForSend.count * 100) + (20 * self.avAssetsForSend.count))
            self.imageScrollView.setNeedsDisplay()
        }
        
        
    }
    
    // MARK: Button - deleteBtnClick
    func deleteImageInScrollView(_ sender: UIButton) {
        

        print("avAssetsForSend beforeDelete: \(self.avAssetsForSend.count)")
        print("avAssetsForSend deleteIndex: \(sender.tag)")
        self.avAssetsForSend.remove(at: sender.tag)
        self.avAssetsForDisplay.remove(at: sender.tag)
        
        print("avAssetsForSend afterDelete: \(self.avAssetsForSend.count)")
        

        if avAssetsForDisplay.count == 0 {
            imageScrollView.isHidden = true
        } else {
            imageScrollView.isHidden = false
            for delete in self.contentView.subviews{
                delete.removeFromSuperview()
            }
            for asset in self.avAssetsForDisplay.enumerated(){
                print("~~~~~~~\(avAssetsForDisplay.count)~~~~~~~~~")
                print("\(asset.offset): \(asset.element)")
                self.addImageAndDeleteBtn(image: asset.element, offset: asset.offset)
            }
        }
        
    }
    
    // MARK: Close Button click
    @IBAction func closeBtnClick(_ sender: Any) {
        print("closeBtn")
//        textView.resignFirstResponder()
        textView.endEditing(true)
        dismiss(animated: true) {
            
        }
        
    }
    
    
    // MARK: Pic Button click
    @IBAction func picBtnClick(_ sender: UIButton) {
        displayAVAssets(whichBtn : .Pic)
    }
    
    // MARK: Video Button click
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
    // MARK: Send Image or Image with Text
    func sendImageOnly(avAssetsForSend : [DKAsset]!) {
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
            
            if platforms.count == 0 {
                print("Non of platforms has been selected")
                return
            }
            
            twitterMgr.sendTweetWithTextandImages(images: _photos, text: textView.text, sendToPlatforms: platforms,  completion: { (array_platforms) in
                print("~~~~~~~~~~1.Twitter sendGroupPhotos DONE~~~~~~~~~~")

                self.facebookMgr.sendGroupPhotos(images: _photos, text: self.textView.text, sendToPlatforms: array_platforms, completion: { (array_platforms) in
                    print("~~~~~~~~~~2.Facebook sendGroupPhotos DONE~~~~~~~~~~")
                })
            })
            
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
    func FB_SendVideoOnly(avAssetsForSend : [DKAsset]!, text: String?) {
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
                        print("Video\(videoData.offset): totalBytesSent: \(totalBytesSent) ,totalExpectedBytes: \(totalExpectedBytes) ,\(String(format:"%.2f",totalBytesSent_double/totalExpectedBytes_double * 100))%")
                    }
                    
                    let downloadFailureHandler = { (error: Error) -> () in
                        print("\(error)")
                    }
                    
                    let videoParams = [
                        "video.mov" : videoData.element,
                        "description" : text!,
                        ] as [String : Any]
                    
                    let videoSendRequest = GraphRequest(graphPath: "me/videos", parameters: videoParams, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion)
                    
                    connection.add(videoSendRequest, batchParameters: ["omit_response_on_success" : false], completion: {(HTTPURLResponse, GraphRequestResult) in
                        print(GraphRequestResult)
                        semaphore2.signal()
                    })
                    connection.networkProgressHandler = downloadProgressHandler
                    connection.networkFailureHandler = downloadFailureHandler
                    
                    connection.start()
                    
                    semaphore2.wait()
                }
                
            }
            
            

            
        }
    }
    
    // MARK: Select Platforms Button click
    @IBAction func selectPlatformsBtnClick(_ sender: UIButton) {
        print("selectPlatformsBtnClick")
//        sender.isSelected = !sender.isSelected
//        platforms.removeAll()
        let sb = UIStoryboard(name: "HAPlatformSelectionController", bundle: nil)
        guard let popoverMenuView = sb.instantiateInitialViewController() else {
            return
        }
        
        popoverMenuView.transitioningDelegate = self
        
        popoverMenuView.modalPresentationStyle = .custom
        
        present(popoverMenuView, animated: true, completion: nil)
        
        
    }
    
    
    
    
    // MARK: Send Button click
    @IBAction func sendBtnClick(_ sender: Any) {

        var imagesForSend = [DKAsset]()
        var videosForSend = [DKAsset]()
        
        //--------------------------------------------send text only
        if textView.text.characters.count != 0 && avAssetsForSend.count == 0{
            FB_SendTextOnly(text: textView.text)
        }
        
        
        if avAssetsForSend.count > 0{
            for avasset in avAssetsForSend {
                if avasset.isVideo == false {
                    imagesForSend.append(avasset)
                } else {
                    videosForSend.append(avasset)
                }
            }
            
        }
        
        // -------------------------------------------send photo(s)
        if imagesForSend.count > 0{
            
            sendImageOnly(avAssetsForSend: imagesForSend)
            
        }
        
        //-------------------------------------------send Video
        if videosForSend.count > 0{
            
            if platforms.count == 0 {
                print("Non of platforms has been selected")
                return
            }
            
            print("start to send video(s)")
            print(videosForSend.count)
            
            twitterMgr.sendTweetWithTextandVideos(avAssetsForSend: videosForSend, text: textView.text, sendToPlatforms: platforms,  completion: { (array_platforms) in
//                self.facebookMgr.FB_SendResumableVideoOnly(avAssetsForSend: videosForSend, text: self.textView.text, sendToPlatforms: array_platforms, completion: { (array_platforms) in })
                self.facebookMgr.FB_SendVideoOnly(avAssetsForSend: videosForSend, text: self.textView.text, sendToPlatforms: array_platforms,  completion:{ (array_platforms) in })
            })
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

extension HAPostVC: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HAPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresent = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
    
}


extension HAPostVC: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresent ? animateTransitionForPresent(transitionContext: transitionContext) : animateTransitionForDismiss(transitionContext: transitionContext)
    }
    
    fileprivate func animateTransitionForPresent(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let presentView = transitionContext.view(forKey: UITransitionContextViewKey.to)  else {
                return
        }
        
        transitionContext.containerView.addSubview(presentView)
        presentView.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
        presentView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            presentView.transform = CGAffineTransform.identity

        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
    fileprivate func animateTransitionForDismiss(transitionContext: UIViewControllerContextTransitioning) {
        guard let dismissView = transitionContext.view(forKey: UITransitionContextViewKey.from)  else {
            return
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            dismissView.transform = CGAffineTransform(scaleX: 1.0, y: 0.001)
        }) { (_) in
            dismissView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
    
}




// MARK: UIImage - HA_resizeImage
extension UIImage {
    class func HA_resizeImage(image: UIImage!) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width * 0.06, height: image.size.height * 0.06)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let picture1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(picture1!)
        let img = UIImage(data: imageData!)
//        print("resized: \(img)")
        return img!
    }
}
