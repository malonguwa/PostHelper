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

class HAPostVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentWidth: NSLayoutConstraint!
    @IBOutlet weak var imageScrollView: UIScrollView!
    var imagePickerManager : HAImagePickerManager = HAImagePickerManager()
    var imageArrayForSend : [DKAsset]?

    
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
            self.imageArrayForSend = imageArray
//            guard let contentView = self.imageScrollView.subviews.first else {
//                return
//            }
            
            for asset in imageArray.enumerated() {
                asset.element.fetchAVAssetWithCompleteBlock({ (AVAsset, info) in
                        print(AVAsset!.duration)
                    
                })
            }
            
            self.imageScrollView.isHidden = false
            self.textView.becomeFirstResponder()
        }
        
        imagePickerManager.addVideo(naviController: self)
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: Send Button click
    @IBAction func sendBtnClick(_ sender: Any) {
        print("start to send")
        
        //send text
        if textView.text.characters.count != 0 {
            GraphRequest(graphPath: "/me/feed", parameters:["message" : textView.text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
                //text send completely
                print("\(response)\n\(requestResult)")
            }
        }
        
        else if imageArrayForSend != nil {
            //send photo(s)
            guard let _imageArrayForSend = imageArrayForSend else {
                print("image Array == nil")
                return
            }
            
            for asset in _imageArrayForSend.enumerated() {
                asset.element.fetchOriginalImage(true, completeBlock: { (image, info) in
                    if image != nil {
                        let photo = Photo(image: image!, userGenerated: true)
                        print(photo.image as UIImage!)
                        let content = PhotoShareContent(photos: [photo])
                        
                        let sharer = GraphSharer(content: content)
                        sharer.failsOnInvalidData = true
                        sharer.completion = { result in
                         // photo send completely
                            
                        }
                        try! sharer.share()
                    }
                })
            }
        }
            
        else {//
            return
        }
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

