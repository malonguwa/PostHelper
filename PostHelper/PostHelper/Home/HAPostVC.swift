//
//  HAPostVC.swift
//  PostHelper
//
//  Created by LONG MA on 17/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookCore

class HAPostVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentWidth: NSLayoutConstraint!
    @IBOutlet weak var imageScrollView: UIScrollView!
    var imagePickerManager : HAImagePickerManager = HAImagePickerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(HAPostVC.keyboardWillChange(notice :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    @IBAction func postClick(_ sender: Any) {

        print("start to send")
        
        GraphRequest(graphPath: "/me/feed", parameters:["message" : textView.text], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.POST, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
            print("\(response)\n\(requestResult)")
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
    
    
    @IBAction func picBtnClick(_ sender: Any) {
        
        imagePickerManager.callBack = {
            self.imageScrollView.isHidden = true
            self.textView.becomeFirstResponder()
        }
        imagePickerManager.addImage(naviController: self)
        
        
    }
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    
    
    
    
    
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

