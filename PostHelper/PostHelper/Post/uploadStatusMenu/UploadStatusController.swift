//
//  HAUploadStatusController.swift
//  PostHelper
//
//  Created by LONG MA on 3/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//
/*
import Foundation
//import DKImagePickerController

class HAUploadStatusController: UITableViewController {
    @IBOutlet weak var TWPhotoUploadView: UIView!
    @IBOutlet weak var TWVideoUploadView: UIView!
    @IBOutlet weak var FBPhotoUploadView: UIView!
    @IBOutlet weak var FBVideoUploadView: UIView!
    
    @IBOutlet weak var doneBtn: UIButton!
    var ringforFBphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 35, height:35))
    var ringforFBvideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 35, height:35))
    var ringforTWphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 35, height:35))
    var ringforTWvideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 35, height:35))

    var flagforFBphoto = 0
    var flagforFBvideo = 0
    var flagforTWphoto = 0
    var flagforTWvideo = 0

    var sendVideo = false
    var sendPhoto = false

    var HAPostVC : HAPostVC?
    
    func restartRingAnimation() {
        ringforFBphoto.indeterminate = ringforFBphoto.indeterminate
        ringforFBvideo.indeterminate = ringforFBvideo.indeterminate
        ringforTWphoto.indeterminate = ringforTWphoto.indeterminate
        ringforTWvideo.indeterminate = ringforTWvideo.indeterminate

    }
    
    override func viewDidLoad() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: UIScreen.main.bounds.size.height * 0.5 - 180))
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HAUploadStatusController.restartRingAnimation),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.frame = UIScreen.main.bounds
        effectView.alpha = 0.8
        tableView.insertSubview(effectView, at: 0)

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
                    ringforTWphoto.primaryColor = UIColor.white
                    ringforTWphoto.secondaryColor = UIColor.white
                    TWPhotoUploadView.addSubview(ringforTWphoto)
                }
                
                if sendVideo == true {
                    ringforTWvideo.indeterminate = true
                    ringforTWvideo.primaryColor = UIColor.white
                    ringforTWvideo.secondaryColor = UIColor.white
                    TWVideoUploadView.addSubview(ringforTWvideo)
                }
            } else {
                tableView.cellForRow(at: IndexPath.init(row: 0, section: 0))?.isHidden = true
                
            }

            if platforms.contains(.HAFacebook){
                FBPhotoUploadView.isHidden = !sendPhoto
                FBVideoUploadView.isHidden = !sendVideo

                if sendPhoto == true {
//                    ringforFBphoto.showPercentage = false
                    ringforFBphoto.indeterminate = true
                    ringforFBphoto.primaryColor = UIColor.white
                    ringforFBphoto.secondaryColor = UIColor.white

                    FBPhotoUploadView.addSubview(ringforFBphoto)
                    print("self.ringforFBphoto: \(self.ringforFBphoto)")

                }
                
                if sendVideo == true {
                    ringforFBvideo.indeterminate = true
                    ringforFBvideo.primaryColor = UIColor.white
                    ringforFBvideo.secondaryColor = UIColor.white

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
                self?.ringforFBphoto.primaryColor = UIColor.green
                self?.ringforFBphoto.secondaryColor = UIColor.green
                self?.flagforFBphoto = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforFBphoto.perform(M13ProgressViewActionFailure, animated: true)
                self?.ringforFBphoto.primaryColor = UIColor.red
                self?.ringforFBphoto.secondaryColor = UIColor.red
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
                self?.ringforTWphoto.primaryColor = UIColor.green
                self?.ringforTWphoto.secondaryColor = UIColor.green

                self?.flagforTWphoto = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforTWphoto.perform(M13ProgressViewActionFailure, animated: true)
                self?.ringforTWphoto.primaryColor = UIColor.red
                self?.ringforTWphoto.secondaryColor = UIColor.red

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
                self?.ringforFBvideo.primaryColor = UIColor.green
                self?.ringforFBvideo.secondaryColor = UIColor.green

                self?.flagforFBvideo = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforFBvideo.perform(M13ProgressViewActionFailure, animated: true)
                self?.ringforFBvideo.primaryColor = UIColor.red
                self?.ringforFBvideo.secondaryColor = UIColor.red

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
                self?.ringforTWvideo.primaryColor = UIColor.green
                self?.ringforTWvideo.secondaryColor = UIColor.green
                self?.flagforTWvideo = 1
                self?.finishUploadCheck(percentage: percentage)

            } else if status == uploadStatus.Failure{
                self?.ringforTWvideo.perform(M13ProgressViewActionFailure, animated: true)
                self?.ringforTWvideo.primaryColor = UIColor.red
                self?.ringforTWvideo.secondaryColor = UIColor.red
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
        HAPostVC?.hideScrollViewBtn.isHidden = true
        HAPostVC?.TwitterWordCount = 0
        HAPostVC?.wordCountLabel.text = "\(140 - (HAPostVC?.TwitterWordCount)!) Twitter, \(63206 - (HAPostVC?.TwitterWordCount)!) Facebook"
        HAPostVC?.placeWordCountLimit()
    }
    
    
    
    private func finishUploadCheck(percentage: CGFloat) {
        
        if percentage == 0.00 {
            doneBtn.backgroundColor = UIColor.red
            doneBtn.titleLabel?.text = "Done"
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
 
 */
