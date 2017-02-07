//
//  HAUploadStatusController.swift
//  PostHelper
//
//  Created by LONG MA on 3/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
import DKImagePickerController

class HAUploadStatusController: UITableViewController {
    @IBOutlet weak var TWPhotoUploadView: UIView!
    @IBOutlet weak var TWVideoUploadView: UIView!
    @IBOutlet weak var FBPhotoUploadView: UIView!
    @IBOutlet weak var FBVideoUploadView: UIView!
    
    @IBOutlet weak var doneBtn: UIButton!
    var ringforFBphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 50, height:50))
    var ringforFBvideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 50, height:50))
    var ringforTWphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 50, height:50))
    var ringforTWvideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 50, height:50))

    var flagforFBphoto = 0
    var flagforFBvideo = 0
    var flagforTWphoto = 0
    var flagforTWvideo = 0

    var sendVideo = false
    var sendPhoto = false

    var HAPostVC : HAPostVC?
    
    
    override func viewDidLoad() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: UIScreen.main.bounds.size.height * 0.5 - 180))
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
   

        for asset in (HAPostVC?.avAssetsForSend)!{
            if asset.isVideo == true {
                sendVideo = true
            } else {
                sendPhoto = true
            }
        }

        
        if platforms.count > 0 {
            
            if platforms[0] == .HATwitter {
                
                TWPhotoUploadView.isHidden = !sendPhoto
                TWVideoUploadView.isHidden = !sendVideo

                if sendPhoto == true {
                    ringforTWphoto.indeterminate = true
                    TWPhotoUploadView.addSubview(ringforTWphoto)
                }
                
                if sendVideo == true {
                    ringforTWvideo.indeterminate = true
                    TWVideoUploadView.addSubview(ringforTWvideo)
                }
            } else {
                tableView.cellForRow(at: IndexPath.init(row: 0, section: 0))?.isHidden = true
                
            }

            if platforms.contains(.HAFacebook){
                FBPhotoUploadView.isHidden = !sendPhoto
                FBVideoUploadView.isHidden = !sendVideo

                if sendPhoto == true {
                    ringforFBphoto.showPercentage = false
                    ringforFBphoto.indeterminate = true
                    
                    FBPhotoUploadView.addSubview(ringforFBphoto)
                    print("self.ringforFBphoto: \(self.ringforFBphoto)")

                }
                
                if sendVideo == true {
                    ringforFBvideo.indeterminate = true
                    FBVideoUploadView.addSubview(ringforFBvideo)
                }
            } else {
                tableView.cellForRow(at: IndexPath.init(row: 1, section: 0))?.isHidden = true
            }

        }
    
        HAPostVC?.facebookMgr.PhotoUpdateUploadStatus = {[weak self] (percentage, status)->() in
//            print("self.ringforFBphoto: \(self.ringforFBphoto)")
//            print("updateUploadStatus closure")
            self?.ringforFBphoto.indeterminate = false
            
            if status == uploadStatus.Success {
                self?.ringforFBphoto.setProgress(100.00, animated: true)
                self?.ringforFBphoto.perform(M13ProgressViewActionSuccess, animated: true)
                self?.flagforFBphoto = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforFBphoto.perform(M13ProgressViewActionFailure, animated: true)
                self?.flagforFBphoto = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Uploading{
                print("FB Photo Uploading.........")
                self?.ringforFBphoto.setProgress(percentage*0.01, animated: true)
            }
        }
        
        HAPostVC?.twitterMgr.PhotoUpdateUploadStatus = {[weak self] (percentage, status)->() in
            //            print("self.ringforFBphoto: \(self.ringforFBphoto)")
            //            print("updateUploadStatus closure")
            self?.ringforTWphoto.indeterminate = false
            
            if status == uploadStatus.Success {
                self?.ringforTWphoto.setProgress(100.00, animated: true)
                self?.ringforTWphoto.perform(M13ProgressViewActionSuccess, animated: true)
                self?.flagforTWphoto = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforTWphoto.perform(M13ProgressViewActionFailure, animated: true)
                self?.flagforTWphoto = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Uploading{
                print("TW Photo Uploading.........")
                self?.ringforTWphoto.setProgress(percentage*0.01, animated: true)
                
            }
        }
        
        HAPostVC?.facebookMgr.VideoUpdateUploadStatus = {[weak self] (percentage, status)->() in
            //            print("self.ringforFBphoto: \(self.ringforFBphoto)")
//            print("updateUploadStatus closure")
            self?.ringforFBvideo.indeterminate = false
            
            if status == uploadStatus.Success {
                self?.ringforFBvideo.setProgress(100.00, animated: true)
                self?.ringforFBvideo.perform(M13ProgressViewActionSuccess, animated: true)
                self?.flagforFBvideo = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforFBvideo.perform(M13ProgressViewActionFailure, animated: true)
                self?.flagforFBvideo = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Uploading{
                print("FB Video Uploading.........")
                self?.ringforFBvideo.setProgress(percentage*0.01, animated: true)
                
            }
        }
        
        HAPostVC?.twitterMgr.VideoUpdateUploadStatus = {[weak self] (percentage, status)->() in
            //            print("self.ringforFBphoto: \(self.ringforFBphoto)")
            //            print("updateUploadStatus closure")
            self?.ringforTWvideo.indeterminate = false
            
            if status == uploadStatus.Success {
                self?.ringforTWvideo.setProgress(100.00, animated: true)
                self?.ringforTWvideo.perform(M13ProgressViewActionSuccess, animated: true)
                self?.flagforTWvideo = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforTWvideo.perform(M13ProgressViewActionFailure, animated: true)
                self?.flagforTWvideo = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Uploading{
                print("TW Video Uploading.........")
                self?.ringforTWvideo.setProgress(percentage*0.01, animated: true)
                
            }
        }
        
    }
    
    @IBAction func doneBtnClick(_ sender: Any) {
        let tempVC = UIApplication.shared.keyWindow?.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = HAPostVC?.currentRootVc
        tempVC?.removeFromParentViewController()
        tempVC?.view.removeFromSuperview()
        
        HAPostVC?.textView.text = ""
        HAPostVC?.placeHolderLabel.isHidden = false
        for imageView in (HAPostVC?.contentView.subviews)! {
            imageView.removeFromSuperview()
        }
        HAPostVC?.avAssetsForDisplay.removeAll()
        HAPostVC?.avAssetsForSend.removeAll()
        HAPostVC?.imagePickerManager.selectedImagesArray.removeAll()
        HAPostVC?.imagePickerManager.selectedVideosArray.removeAll()
        HAPostVC?.imageScrollView.isHidden = true
        HAPostVC?.sendBtn.isEnabled = false
        HAPostVC?.textView.becomeFirstResponder()
        
    }
    
    
    
    private func finishUploadCheck(percentage: CGFloat) {
        
        if percentage == 0.00 {
            doneBtn.backgroundColor = UIColor.red
            doneBtn.titleLabel?.text = "Failed to upload some files"
        }
        
        if platforms.count == 2 {
            
            if sendVideo == true && sendPhoto == true && flagforFBphoto + flagforFBvideo + flagforTWvideo + flagforTWphoto == 4{
               doneBtn.isHidden = false
            } else if sendVideo == true && sendPhoto == false && flagforFBphoto + flagforFBvideo + flagforTWvideo + flagforTWphoto == 2{
                doneBtn.isHidden = false
            } else if sendVideo == false && sendPhoto == true && flagforFBphoto + flagforFBvideo + flagforTWvideo + flagforTWphoto == 2{
                doneBtn.isHidden = false
            }
        } else if platforms.count == 1 {
            
            if sendVideo == true && sendPhoto == true && flagforFBphoto + flagforFBvideo + flagforTWvideo + flagforTWphoto == 2{
                doneBtn.isHidden = false
            } else if sendVideo == true && sendPhoto == false && flagforFBphoto + flagforFBvideo + flagforTWvideo + flagforTWphoto == 1{
                doneBtn.isHidden = false
            } else if sendVideo == false && sendPhoto == true && flagforFBphoto + flagforFBvideo + flagforTWvideo + flagforTWphoto == 1{
                doneBtn.isHidden = false
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("HAUploadStatusController deinit")
    }
    
}
