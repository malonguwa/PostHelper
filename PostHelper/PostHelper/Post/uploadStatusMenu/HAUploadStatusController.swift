//
//  HAUploadStatusController.swift
//  PostHelper
//
//  Created by LONG MA on 1/3/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAUploadStatusController : UIViewController {
    
    @IBOutlet weak var TWBaseView: UIView!
    @IBOutlet weak var FBBaseView: UIView!
    @IBOutlet weak var TWRingView: UIView!
    @IBOutlet weak var FBRingView: UIView!
    
    @IBOutlet weak var TWImageLabel: UILabel!
    @IBOutlet weak var TWVideoLabel: UILabel!
    @IBOutlet weak var FBImageLabel: UILabel!
    @IBOutlet weak var FBVideoLabel: UILabel!
    
    @IBOutlet weak var TWLogoImageView: UIImageView!
    @IBOutlet weak var FBLogoImageView: UIImageView!
    
    @IBOutlet weak var dismissLabel: UILabel!
    
    weak var currentRootVc: UIViewController!
    weak var postVC : HAPostController!
    
    
    var TWBaseVewIsHidden: Bool = false
    var FBBaseVewIsHidden: Bool = false
    var imagesCount: Int = 0
    var videoCount: Int = 0
    var TWsuccessImageCount = 0
//    var TWsuccessVideoCount = 0
    var FBsuccessImageCount = 0
    var TWImageFinalEnd: Bool?
    var TWVideoFinalEnd: Bool?
    var FBImageFinalEnd: Bool?
    var FBVideoFinalEnd: Bool?
    

    
    override func viewDidLoad() {
        
        TWBaseView.isHidden = TWBaseVewIsHidden
        FBBaseView.isHidden = FBBaseVewIsHidden
        
        view.insertSubview(HAPostHUDViewBuilder.createBlurView(), at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HAUploadStatusController.updateLabelInfor(notification:)), name: NSNotification.Name(rawValue: "HApostStatusUpdateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HAUploadStatusController.updateFinalLogo(notification:)), name: NSNotification.Name(rawValue: "HAfinalPostStatusNotification"), object: nil)


        setUpRingView()
        setUpLabel()
    }
    
    func updateLabelInfor(notification: Notification) {
        let platform = notification.userInfo?["currentPlatform"] as! SocialPlatform
        
        if platform == SocialPlatform.HATwitter && notification.userInfo?["isSuccess"] as! Bool == true {
            if notification.userInfo?["isVideo"] as! Bool == false {//Image
                TWsuccessImageCount = TWsuccessImageCount + 1
                TWImageLabel.text = "\(TWsuccessImageCount)/\(imagesCount > 4 ? 4 : imagesCount)"
            } else {// video
                TWVideoLabel.text = "1/\(videoCount)"
            }
        }

        if platform == SocialPlatform.HAFacebook && notification.userInfo?["isSuccess"] as! Bool == true{
            if notification.userInfo?["isVideo"] as! Bool == false {//Image
                FBsuccessImageCount = FBsuccessImageCount + 1
                print("FBsuccessImageCount: \(FBsuccessImageCount)")
                FBImageLabel.text = "\(FBsuccessImageCount)/\(imagesCount)"
            } else {// video
                FBVideoLabel.text = "1/\(videoCount)"
            }
        }
        

    }
    
    //FIXME: Not finish yet
    //HASocialPlatformsBaseManager类里的发通知方法还未完成
    //接到通知，判断是哪个FinalEND了， 然后把对应的TWImageFinalEnd, TWVideoFinalEnd, FBImageFinalEnd, FBVideoFinalEnd赋值成true
    //当TWImageFinalEnd, TWVideoFinalEnd都为true时，就把对应的Logo变成无缝圆圈
    func updateFinalLogo(notification: Notification) {
        let whoEnd = notification.userInfo?["whoFinalEND"] as! WhoUploadEnd

        if whoEnd == WhoUploadEnd.TWImageFinalEND {
            TWImageFinalEnd = true
        } else if whoEnd == WhoUploadEnd.TWVideoFinalEND {
            TWVideoFinalEnd = true
        } else if whoEnd == WhoUploadEnd.FBImageFinalEND {
            FBImageFinalEnd = true
        } else if whoEnd == WhoUploadEnd.FBVideoFinalEND {
            FBVideoFinalEnd = true
        }
        
        print(whoEnd)
        print(videoCount)

        if videoCount != 0 {
            if TWVideoFinalEnd == true {
                
                TWRingView.subviews[0].removeFromSuperview()
                let ringforTW = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
                ringforTW.indeterminate = false
                ringforTW.secondaryColor = UIColor(colorLiteralRed: 0.0/255.0, green: 162.0/255.0, blue: 236.0/255.0, alpha: 1.0)
                ringforTW.showPercentage = false
                TWRingView.insertSubview(ringforTW, at: 0)
                
            }
            
            if FBVideoFinalEnd == true {
                
                FBRingView.subviews[0].removeFromSuperview()
                let ringforFB = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
                ringforFB.indeterminate = false
                ringforFB.secondaryColor = UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                ringforFB.showPercentage = false
                FBRingView.insertSubview(ringforFB, at: 0)
            }
            
            if platforms.count == 2 {
                if FBVideoFinalEnd == true {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                    view.subviews[0].addGestureRecognizer(tapGesture)
                    dismissLabel.isHidden = false
                }
            } else {
                if TWVideoFinalEnd == true || FBVideoFinalEnd == true {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                    view.subviews[0].addGestureRecognizer(tapGesture)
                    dismissLabel.isHidden = false
                }
            }

            
        } else { //videoCount == 0
            if TWImageFinalEnd == true {
                TWRingView.subviews[0].removeFromSuperview()
                let ringforTW = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
                ringforTW.indeterminate = false
                ringforTW.secondaryColor = UIColor(colorLiteralRed: 0.0/255.0, green: 162.0/255.0, blue: 236.0/255.0, alpha: 1.0)
                ringforTW.showPercentage = false
                TWRingView.insertSubview(ringforTW, at: 0)
                
            }
            
            if FBImageFinalEnd == true {
                
                FBRingView.subviews[0].removeFromSuperview()
                let ringforFB = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
                ringforFB.indeterminate = false
                ringforFB.secondaryColor = UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                ringforFB.showPercentage = false
                FBRingView.insertSubview(ringforFB, at: 0)
            }
            
            if platforms.count == 2 {
                if FBImageFinalEnd == true {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                    view.subviews[0].addGestureRecognizer(tapGesture)
                    dismissLabel.isHidden = false

                }
            } else {
                if TWImageFinalEnd == true || FBImageFinalEnd == true {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                    view.subviews[0].addGestureRecognizer(tapGesture)
                    dismissLabel.isHidden = false

                }
            }
            
        }
        

    }
    
    
    
    
    
    func setUpRingView() {
        let ringforFB = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ringforFB.indeterminate = true
        ringforFB.secondaryColor = UIColor.white
        FBRingView.insertSubview(ringforFB, at: 0)
        
        let ringforTW = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ringforTW.indeterminate = true
        
//        ringforTW.backgroundRingWidth = 5
//        ringforTW.primaryColor = UIColor.white
//        ringforTW.backgroundColor = UIColor.white
//        ringforTW.tintColor = UIColor.white
        ringforTW.secondaryColor = UIColor.white
        TWRingView.insertSubview(ringforTW, at: 0)
        
//        TWRingView.subviews[0].removeFromSuperview()
//        TWRingView.insertSubview(<#T##view: UIView##UIView#>, at: 0)
    }
    
    
    func setUpLabel(){
        if TWBaseView.isHidden == false {
            TWImageLabel.text = "0/\(imagesCount > 4 ? 4 : imagesCount)"
            TWVideoLabel.text = "0/\(videoCount)"
        }
        
        if FBBaseView.isHidden == false {
            FBImageLabel.text = "0/\(imagesCount)"
            FBVideoLabel.text = "0/\(videoCount)"

        }
    }
    
    
    //MARK: TapGesture
    @objc fileprivate func tapOnBlurView(gesture : UITapGestureRecognizer) {
//        let RootVc = UIApplication.shared.keyWindow?.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = currentRootVc
        postVC.scrollView.isHidden = true
        postVC.galleryArrowBtn.isHidden = true
//        postVC.wordCountLabel.frame.origin = CGPoint(x: 0, y: 248)
        postVC.placeWordCountLimit()
        postVC.wordCountLabelMove = true
        postVC.arrayForDisplay.removeAll()
        postVC.imageInGalleryArray.removeAll()
        postVC.videoInGalleryArray.removeAll()
        postVC.selected_assets.removeAllObjects()
        postVC.textView.text = ""
        postVC.sendBtn.isEnabled = false
        
    }

    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("HAUploadStatusController deinit")
    }
    
    
    
    
    
}


