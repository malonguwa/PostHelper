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
    var imageArrayForSend : [DKAsset]?
    var videoArrayForSend : [DKAsset]?


    
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
        
        imagePickerManager.selectedImages = { (imageArray) in
            self.imageArrayForSend = imageArray
            guard let contentView = self.imageScrollView.subviews.first else {
                return
            }
            
            for asset in imageArray.enumerated() {
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
        
        imagePickerManager.selectedImages = { (imageArray) in
            self.videoArrayForSend = imageArray
            
            guard let contentView = self.imageScrollView.subviews.first else {
                return
            }

            

           self.videoArrayForSend![0].fetchAVAssetWithCompleteBlock({ (Asset, info) in
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
    
    // MARK: Send Button click
    @IBAction func sendBtnClick(_ sender: Any) {
        print("start to send")
        
        //--------------------------------------------send text
        if textView.text.characters.count != 0 {
            GraphRequest(graphPath: "/me/feed", parameters:["message" : textView.text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
                //text send completely
                print("text send completely + \(response)\n\(requestResult)\n")

                self.textView.text = ""
            }
        }
        
        // -------------------------------------------send photo(s)
        if imageArrayForSend != nil {
            guard let _imageArrayForSend = imageArrayForSend else {
                print("image Array == nil")
                return
            }
            
            //TODO:todo 1.发送多张图片循环优化
            var _photos = [Photo]()
            for asset in _imageArrayForSend.enumerated() {
                asset.element.fetchOriginalImage(true, completeBlock: { (image, info) in
                    
                    if image != nil {
                        let photo = Photo(image: image!, userGenerated: true)
                        _photos.append(photo)
//                        print(photo.image as UIImage!)
                        
                    }
                    
                })
            }
        let content = PhotoShareContent(photos: _photos)
        let sharer = GraphSharer(content: content)
        sharer.failsOnInvalidData = true
        sharer.completion = { result in
            // photo send completely
            print("photo send completely + \(result)\n")
            for imageView in self.imageScrollView.subviews[0].subviews {
                if imageView is UIImageView {
                    imageView.removeFromSuperview()
                }
            }
            self.imageArrayForSend?.removeAll()
            
        }
        try! sharer.share()
        
        
        }
        
        
        //-------------------------------------------send Video
        if videoArrayForSend != nil {
            
            guard let _videoArrayForSend = videoArrayForSend else {
                print("image Array == nil")
                return
            }
            
            for asset in _videoArrayForSend.enumerated() {
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
                        self.videoArrayForSend?.removeAll()
                        
                        
                    }
                    try! sharer.share()
                    
                    
                    //                    print("~~~\(avurl.url)~~~\n")
                })
            }
        }
        
//        else {//
//            return
//        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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

