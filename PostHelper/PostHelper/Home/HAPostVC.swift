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

        
        imagePickerManager.HnA_selectedAVAssets = { (combinedArray) in

            print("DONE \(combinedArray)")
            
            if combinedArray.count > 0 {
                self.sendBtn.isEnabled = true
            } else if combinedArray.count == 0 && self.textView.text.lengthOfBytes(using: .utf8) == 0{
                self.sendBtn.isEnabled = false
            }
            
            //HnA_DKAssetArray 当前选择的
            //combinedArray image+video一共选择的
            if combinedArray.count == 0 {
                self.imageScrollView.isHidden = true
                self.textView.becomeFirstResponder()
                return
            }
            
            self.avAssetsForDisplay.removeAll()
            self.avAssetsForSend.removeAll()

            for imageView in self.contentView.subviews {
                imageView.removeFromSuperview()
            }
            
//            self.avAssetsForSend.append(contentsOf: HnA_DKAssetArray)
            self.avAssetsForSend.append(contentsOf: combinedArray)

            print(self.avAssetsForSend.count)
            
            let serialQueue2 = DispatchQueue(label: "serialQ2ForAVSelection")
            
            for asset in combinedArray.enumerated() {
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
            print("avAssetsForSend.count: \(self.avAssetsForSend.count)")
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
    func deleteImageInScrollView(_ sender: UIButton?) {
        print("deleteImageInScrollView\(sender!.tag)")
        print("avAssetsForSend beforeDelete: \(self.avAssetsForSend.count)")
        print("avAssetsForSend deleteIndex: \(sender!.tag)")
        self.avAssetsForSend.remove(at: sender!.tag)
        self.avAssetsForDisplay.remove(at: sender!.tag)
        
        if self.avAssetsForDisplay.count > 0 {
            self.sendBtn.isEnabled = true
        } else if textView.text.lengthOfBytes(using: .utf8) == 0 && self.avAssetsForDisplay.count == 0{
            self.sendBtn.isEnabled = false
        }
        
        var images = [DKAsset]()
        var videos = [DKAsset]()
        for asset in avAssetsForSend.enumerated() {
            
            if asset.element.isVideo == false {//Image
                images.append(asset.element)
            } else {//Video
                videos.append(asset.element)
            }
        }
        imagePickerManager.selectedImagesArray = images
        imagePickerManager.selectedVideosArray = videos

        
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
        
        print("+++++++&&&&&&&&&&+++++++ \(self.avAssetsForSend.count) ---> \(self.avAssetsForSend)")
        
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
                //FIXME: - Add HUD here!!
                return
            }
            
            twitterMgr.sendTweetWithTextandImages(images: _photos, text: textView.text, sendToPlatforms: platforms,  completion: { (array_platforms) in
                print("~~~~~~~~~~1.Twitter sendGroupPhotos DONE~~~~~~~~~~")

                self.facebookMgr.sendGroupPhotos(images: _photos, text: self.textView.text, sendToPlatforms: array_platforms, completion: { (array_platforms) in
                    print("~~~~~~~~~~2.Facebook sendGroupPhotos DONE~~~~~~~~~~")
//                    for index in self.avAssetsForDisplay.enumerated() {
//                        let tempBtn = UIButton()
//                        tempBtn.tag = index.offset
//                        self.deleteImageInScrollView(tempBtn)
//                    }
//                    self.textView.text = ""
//                    self.placeHolderLabel.alpha = 1
//                    self.sendBtn.isEnabled = false
                    
                    self.textView.text = ""
                    self.placeHolderLabel.alpha = 1
                    for imageView in self.contentView.subviews {
                        imageView.removeFromSuperview()
                    }
                    self.avAssetsForDisplay.removeAll()
                    self.avAssetsForSend.removeAll()
                    self.imagePickerManager.selectedImagesArray.removeAll()
                    self.imagePickerManager.selectedVideosArray.removeAll()
                    self.imageScrollView.isHidden = true
                    self.sendBtn.isEnabled = false
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
    
    // MARK: Select Platforms Button click
    @IBAction func selectPlatformsBtnClick(_ sender: UIButton) {
        print("selectPlatformsBtnClick")
//        sender.isSelected = !sender.isSelected
//        platforms.removeAll()
        let sb = UIStoryboard(name: "HAPlatformSelectionController", bundle: nil)
        guard let popoverMenuViewController = sb.instantiateInitialViewController() else {
            return
        }
        
        popoverMenuViewController.transitioningDelegate = self
        
        popoverMenuViewController.modalPresentationStyle = .custom
        
        present(popoverMenuViewController, animated: true, completion: nil)
        
        
    }
    
    // MARK: Send Button click
    @IBAction func sendBtnClick(_ sender: Any) {
        self.textView.resignFirstResponder()
        
        let sb = UIStoryboard(name: "HAUploadStatusController", bundle: nil)
        guard let uploadStatusMenuTableViewController = sb.instantiateInitialViewController() as? HAUploadStatusController else {
            return
        }
        uploadStatusMenuTableViewController.HAPostVC = self
        let tempVC = UIApplication.shared.keyWindow?.rootViewController
        print("\( UIApplication.shared.keyWindow?.rootViewController)")
        print("\( tempVC)")

        UIApplication.shared.keyWindow?.rootViewController = uploadStatusMenuTableViewController

        
        
//        UIApplication.shared.keyWindow?.addSubview(uploadStatusMenuTableViewController.tableView)
        
//        UIApplication.shared.keyWindow?.subviews[(UIApplication.shared.keyWindow?.subviews.count)! - 1].removeFromSuperview()
//        show(uploadStatusMenuTableViewController, sender: nil)
        
//        present(uploadStatusMenuTableViewController, animated: true, completion: nil)

        
//        return
        
        
        var imagesForSend = [DKAsset]()
        var videosForSend = [DKAsset]()
        
        //--------------------------------------------send text only
        if textView.text.characters.count != 0 && avAssetsForSend.count == 0{
            twitterMgr.sendTweetWithTextOnly(text: textView.text, sendToPlatforms: platforms, completion: { (array_platforms) in
                self.facebookMgr.sendTextOnly(text: self.textView.text, sendToPlatforms: platforms, completion: { (array_platforms) in
                    self.textView.text = ""
                    self.placeHolderLabel.alpha = 1
                })
            })
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
                //FIXME: - Add HUD here!!
                return
            }
            
            print("start to send video(s)")
            print(videosForSend.count)
//            var videoText = textView.text
            twitterMgr.sendTweetWithTextandVideos(avAssetsForSend: videosForSend, text: textView.text, sendToPlatforms: platforms,  completion: { (array_platforms) in
                
                self.facebookMgr.FB_SendVideoOnly(avAssetsForSend: videosForSend, text: self.textView.text, sendToPlatforms: array_platforms,  completion:{ (array_platforms) in
                    self.textView.text = ""
                    self.placeHolderLabel.alpha = 1
                    for imageView in self.contentView.subviews {
                        imageView.removeFromSuperview()
                    }
                    self.avAssetsForDisplay.removeAll()
                    self.avAssetsForSend.removeAll()
                    self.imagePickerManager.selectedImagesArray.removeAll()
                    self.imagePickerManager.selectedVideosArray.removeAll()
                    self.imageScrollView.isHidden = true
                    self.sendBtn.isEnabled = false
                })
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
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        textView.resignFirstResponder()
    }
}

// MARK: UITextViewDelegate
extension HAPostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        print("\(textView.text.characters.count)")
        textView.becomeFirstResponder()
        if textView.text.lengthOfBytes(using: .utf8) > 0{
            sendBtn.isEnabled = true
            self.placeHolderLabel.isHidden = true
            
        } else if avAssetsForDisplay.count == 0 && textView.text.lengthOfBytes(using: .utf8) == 0{
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
