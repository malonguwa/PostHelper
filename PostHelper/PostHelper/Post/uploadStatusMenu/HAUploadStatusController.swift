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
    var FBsuccessImageCount = 0
    
    var TWvideoSuccessCount = 0
    var FBvideoSuccessCount = 0

    var TWImageFinalEnd: Bool?
    var TWVideoFinalEnd: Bool?
    var FBImageFinalEnd: Bool?
    var FBVideoFinalEnd: Bool?
    
    var TWFinalEndCount = 0
    var FBFinalEndCount = 0
    
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    override func viewDidLoad() {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        TWBaseView.isHidden = TWBaseVewIsHidden
        FBBaseView.isHidden = FBBaseVewIsHidden
        
        view.insertSubview(HAPostHUDViewBuilder.createBlurView(), at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HAUploadStatusController.updateLabelInfor(notification:)), name: NSNotification.Name(rawValue: "HApostStatusUpdateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HAUploadStatusController.updateFinalLogo(notification:)), name: NSNotification.Name(rawValue: "HAfinalPostStatusNotification"), object: nil)

        

        setUpRingView()
        setUpLabel()
        
        registerBackgroundTask()
    }
    

    
    
    
    
    
    func updateLabelInfor(notification: Notification) {
        let platform = notification.userInfo?["currentPlatform"] as! SocialPlatform
        
        print("TwitterVideo: \(notification.userInfo?["isVideo"]), isSuccess: \(notification.userInfo?["isSuccess"])")

        if platform == SocialPlatform.HATwitter && notification.userInfo?["isSuccess"] as! Bool == true {
            if notification.userInfo?["isVideo"] as! Bool == false {//Image
                TWsuccessImageCount = TWsuccessImageCount + 1
//                TWImageLabel.text = "\(TWsuccessImageCount)/\(imagesCount > 4 ? 4 : imagesCount)"
            } else {// video
                TWvideoSuccessCount = 1
//                TWVideoLabel.text = "1/\(videoCount)"
            }
        }

        if platform == SocialPlatform.HAFacebook && notification.userInfo?["isSuccess"] as! Bool == true{
            if notification.userInfo?["isVideo"] as! Bool == false {//Image
                FBsuccessImageCount = FBsuccessImageCount + 1
                print("FBsuccessImageCount: \(FBsuccessImageCount)")
//                FBImageLabel.text = "\(FBsuccessImageCount)/\(imagesCount)"
            } else {// video
                FBvideoSuccessCount = 1
//                FBVideoLabel.text = "1/\(videoCount)"
            }
        }
        

    }
    
    //FIXME: Not finish yet
    //HASocialPlatformsBaseManager类里的发通知方法还未完成
    //接到通知，判断是哪个FinalEND了， 然后把对应的TWImageFinalEnd, TWVideoFinalEnd, FBImageFinalEnd, FBVideoFinalEnd赋值成true
    //当TWImageFinalEnd, TWVideoFinalEnd都为true时，就把对应的Logo变成无缝圆圈
    func updateFinalLogo(notification: Notification) {
        
        endBackgroundTask()

        let isFinalSucess = notification.userInfo?["isFinalRequestSucess"] as! Bool

        let whoEnd = notification.userInfo?["whoFinalEND"] as! WhoUploadEnd

        if whoEnd == WhoUploadEnd.TWImageFinalEND {
            TWImageFinalEnd = true
            TWFinalEndCount = TWFinalEndCount + 1
        } else if whoEnd == WhoUploadEnd.TWVideoFinalEND {
            TWVideoFinalEnd = true
            TWFinalEndCount = TWFinalEndCount + 1

        } else if whoEnd == WhoUploadEnd.FBImageFinalEND {
            FBImageFinalEnd = true
            FBFinalEndCount = FBFinalEndCount + 1

        } else if whoEnd == WhoUploadEnd.FBVideoFinalEND {
            FBVideoFinalEnd = true
            FBFinalEndCount = FBFinalEndCount + 1
        }
        
        print(whoEnd)
        print(videoCount)
        

        if videoCount != 0 {
            
            //FIXME: 这里需要增加一个通知信息判断，是否FinalEnd成功了，如果成功了再给label赋值，如果失败了不论多少张相片或者视频上传成功，最终结果都应该显示是0/几
            if TWVideoFinalEnd == true {
                if isFinalSucess == true {
                    TWImageLabel.text = "\(TWsuccessImageCount)/\(imagesCount > 4 ? 4 : imagesCount)"
                    TWVideoLabel.text = "\(TWvideoSuccessCount)/1"
                } else {
                    TWImageLabel.text = "0/\(imagesCount > 4 ? 4 : imagesCount)"
                    TWVideoLabel.text = "\(TWvideoSuccessCount)/1"
                }
                updateFinalRingStatus(whichRingView: "TWRingView")
            }
            
            if FBVideoFinalEnd == true {
                if isFinalSucess == true {
                    FBImageLabel.text = "\(FBsuccessImageCount)/\(imagesCount)"
                    FBVideoLabel.text = "\(FBvideoSuccessCount)/1"
                } else {
                    FBImageLabel.text = "0/\(imagesCount)"
                    FBVideoLabel.text = "\(FBvideoSuccessCount)/1"
                }

                updateFinalRingStatus(whichRingView: "FBRingView")
            }
            
            if platforms.count == 2 {//有video

                if imagesCount != 0 {//有Image
                    if FBImageFinalEnd == true && FBVideoFinalEnd == true {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                        view.subviews[0].addGestureRecognizer(tapGesture)
                        dismissLabel.isHidden = false
                    }
                    
                } else {
                    if FBVideoFinalEnd == true {
                        
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                        view.subviews[0].addGestureRecognizer(tapGesture)
                        dismissLabel.isHidden = false
                    }
                }
                
                
                
                
                
                
            } else {
                if TWVideoFinalEnd == true || FBVideoFinalEnd == true {
                    
                    
                    if imagesCount != 0 && videoCount != 0{
                        if TWFinalEndCount == 2 || FBFinalEndCount == 2 {
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                            view.subviews[0].addGestureRecognizer(tapGesture)
                            dismissLabel.isHidden = false
                        }
                    } else {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
                        view.subviews[0].addGestureRecognizer(tapGesture)
                        dismissLabel.isHidden = false
                    }
                }
            }

            
        } else { //videoCount == 0
            if TWImageFinalEnd == true {
                if isFinalSucess == true {
                    TWImageLabel.text = "\(TWsuccessImageCount)/\(imagesCount > 4 ? 4 : imagesCount)"
                } else {
                    TWImageLabel.text = "0/\(imagesCount > 4 ? 4 : imagesCount)"
                }

                updateFinalRingStatus(whichRingView: "TWRingView")
                
            }
            
            if FBImageFinalEnd == true {
                if isFinalSucess == true {
                    FBImageLabel.text = "\(FBsuccessImageCount)/\(imagesCount)"
                } else {
                    FBImageLabel.text = "0/\(imagesCount)"
                }
                
                updateFinalRingStatus(whichRingView: "FBRingView")
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
    
    
    func updateFinalRingStatus(whichRingView: String){
        let ring = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ring.indeterminate = false
        ring.showPercentage = false
//        print("FBVideoLabel: \(FBVideoLabel.text)")
//        print("FBVideoLabel startIndex: \(FBVideoLabel.text?.startIndex)")
//
//        let toIndex = FBVideoLabel.text?.index((FBVideoLabel.text?.startIndex)!, offsetBy: 1)
//        let TWvideoSuccessCount = TWVideoLabel.text?.substring(to: toIndex!)
//        let FBvideoSuccessCount = FBVideoLabel.text?.substring(to: toIndex!)
        
        if imagesCount != 0 && videoCount != 0 {
            
            
            if platforms.count != 2 {
                if platforms.contains(SocialPlatform.HATwitter) {
                    if TWFinalEndCount != 2 {
                        return
                    }
                }

                if platforms.contains(SocialPlatform.HAFacebook){
                    if FBFinalEndCount != 2 {
                        return
                    }
                }
            }
            
            
//            if platforms.count == 2 {
//
//                if TWFinalEndCount == 2 && FBFinalEndCount != 2 {
//                }
//            } else {
//                if platforms.contains(SocialPlatform.HATwitter) {
//                    if TWFinalEndCount != 2 {
//                        return
//                    }
//                }
//                
//                if platforms.contains(SocialPlatform.HAFacebook){
//                    if FBFinalEndCount != 2 {
//                        return
//                    }
//                }
//            }
        
        }
        
        //FIXME: 这里需要增加一个&&判断条件 照片最终post请求成功（根据PhotoIds发送的最终发帖请求）
        if whichRingView == "TWRingView" {
            print("whichRingView == \"TWRingView\"")

            TWRingView.subviews[0].removeFromSuperview()
            
            if videoCount != 0 {
                if TWsuccessImageCount == (imagesCount > 4 ? 4 : imagesCount) && TWvideoSuccessCount == 1{
                    ring.secondaryColor = UIColor.green
                } else {
                    ring.secondaryColor = UIColor.red
                }
            } else {
                if TWsuccessImageCount == (imagesCount > 4 ? 4 : imagesCount) || TWvideoSuccessCount == 1 {
                    ring.secondaryColor = UIColor.green
                } else {
                    ring.secondaryColor = UIColor.red
                }
            }
            
            TWRingView.insertSubview(ring, at: 0)

        } else if whichRingView == "FBRingView" {
            print("whichRingView == \"FBRingView\"")
            
            if imagesCount != 0 && videoCount != 0 {
                if FBFinalEndCount == 2 {
                    FBRingView.subviews[0].removeFromSuperview()
                } else {
                    return
                }
            } else {
                FBRingView.subviews[0].removeFromSuperview()
            }
            
            if videoCount != 0 {
                
                if FBImageFinalEnd == true && FBVideoFinalEnd == true {//混发
                    print("混发")
                    if FBsuccessImageCount == imagesCount && FBvideoSuccessCount == 1 {
                        ring.secondaryColor = UIColor.green
                    } else {
                        ring.secondaryColor = UIColor.red
                    }

                }
                
                if imagesCount == 0 && FBVideoFinalEnd == true {//只发Video
                    print("只发Video")

                    if FBvideoSuccessCount == 1 {
                        ring.secondaryColor = UIColor.green
                    } else {
                        ring.secondaryColor = UIColor.red
                    }
                }
            } else if videoCount == 0 && imagesCount != 0{//只发图片
                if FBsuccessImageCount == imagesCount {
                    ring.secondaryColor = UIColor.green
                } else {
                    ring.secondaryColor = UIColor.red
                    print("FBvideoSuccessCount 2 : \(FBvideoSuccessCount)")

                }
            }


            FBRingView.insertSubview(ring, at: 0)

        }
        
   
    }
    
    
    func setUpRingView() {
        let ringforFB = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ringforFB.indeterminate = true
        ringforFB.secondaryColor = UIColor.white
        FBRingView.insertSubview(ringforFB, at: 0)
        
        let ringforTW = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ringforTW.indeterminate = true
        ringforTW.secondaryColor = UIColor.white
        TWRingView.insertSubview(ringforTW, at: 0)
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
        
        let TWring = TWRingView.subviews[0] as! M13ProgressViewRing
        let FBring = FBRingView.subviews[0] as! M13ProgressViewRing
        let TWringColor = TWring.secondaryColor
        let FBringColoer = FBring.secondaryColor
        if TWringColor != UIColor.red && FBringColoer != UIColor.red {
            if postVC.galleryArrowBtn.isSelected == true {
                
                postVC.contentView.superview?.frame.origin.x = 0
                postVC.galleryArrowBtn.transform = CGAffineTransform(rotationAngle: 0.0)
                postVC.galleryArrowBtn.isSelected = false
            }
            
            postVC.scrollView.isHidden = true
            postVC.galleryArrowBtn.isHidden = true
            postVC.wordCountLabel.frame.origin = CGPoint(x: 0, y: 248)
            //        postVC.placeWordCountLimit()
            postVC.wordCountLabelMove = true
            postVC.arrayForDisplay.removeAll()
            postVC.imageInGalleryArray.removeAll()
            postVC.videoInGalleryArray.removeAll()
            postVC.selected_assets.removeAllObjects()
            postVC.textView.text = ""
            postVC.wordCountLabel.text = "140 Twitter, 63206 Facebook"
            postVC.sendBtn.isEnabled = false
        }
    }

    
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self)
        print("HAUploadStatusController deinit")
    }
    
    
    
    
    
}


