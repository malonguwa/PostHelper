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
    
    var ringforFBphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 50, height:50))
    var ringforFBvideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 50, height:50))

    var HAPostVC : HAPostVC?
    
    
    override func viewDidLoad() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: UIScreen.main.bounds.size.height * 0.5 - 180))
        tableView.tableFooterView = UIView(frame: CGRect.zero)
   

        var sendVideo = false
        var sendPhoto = false

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
                    let ringforTWphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: TWPhotoUploadView.frame.size.width, height:TWPhotoUploadView.frame.size.height))
                    ringforTWphoto.indeterminate = true
                    TWPhotoUploadView.addSubview(ringforTWphoto)
                }
                
                if sendVideo == true {
                    let ringforTWVideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: TWVideoUploadView.frame.size.width, height:TWVideoUploadView.frame.size.height))
                    ringforTWVideo.indeterminate = true
                    TWVideoUploadView.addSubview(ringforTWVideo)
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
                    
//                    let ringforFBphoto = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: TWPhotoUploadView.frame.size.width, height:FBPhotoUploadView.frame.size.height))
                    FBPhotoUploadView.addSubview(ringforFBphoto)
                    print("self.ringforFBphoto: \(self.ringforFBphoto)")

                }
                
                if sendVideo == true {
//                    let ringforFBVideo = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: TWVideoUploadView.frame.size.width, height:FBVideoUploadView.frame.size.height))
                    ringforFBvideo.indeterminate = true
                    FBVideoUploadView.addSubview(ringforFBvideo)
                }
            } else {
                tableView.cellForRow(at: IndexPath.init(row: 1, section: 0))?.isHidden = true
            }

        }
    
        HAPostVC?.facebookMgr.PhotoUpdateUploadStatus = {(percentage, status)->() in
//            print("self.ringforFBphoto: \(self.ringforFBphoto)")
//            print("updateUploadStatus closure")
            self.ringforFBphoto.indeterminate = false

            if status == uploadStatus.Success {
                self.ringforFBphoto.perform(M13ProgressViewActionSuccess, animated: true)

            } else if status == uploadStatus.Failure{
                self.ringforFBphoto.perform(M13ProgressViewActionFailure, animated: true)

            } else if status == uploadStatus.Uploading{
                print("Photo Uploading.........")
                self.ringforFBphoto.setProgress(percentage*0.01, animated: true)

            }
        }
        
        HAPostVC?.facebookMgr.VideoUpdateUploadStatus = {(percentage, status)->() in
            //            print("self.ringforFBphoto: \(self.ringforFBphoto)")
//            print("updateUploadStatus closure")
            self.ringforFBvideo.indeterminate = false
            
            if status == uploadStatus.Success {
                self.ringforFBvideo.perform(M13ProgressViewActionSuccess, animated: true)
                
            } else if status == uploadStatus.Failure{
                self.ringforFBvideo.perform(M13ProgressViewActionFailure, animated: true)
                
            } else if status == uploadStatus.Uploading{
                print("Video Uploading.........")
                self.ringforFBvideo.setProgress(percentage*0.01, animated: true)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        
    }
    
}
