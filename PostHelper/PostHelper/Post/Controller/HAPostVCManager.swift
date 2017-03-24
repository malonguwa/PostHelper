//
//  HAPostVCManager.swift
//  PostHelper
//
//  Created by LONG MA on 16/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAPostVCManager: NSObject {

    weak var postVC : HAPostController!
    fileprivate lazy var isPresented : Bool = false
    
    //MARK: TapGesture
   @objc fileprivate func tapOnBlurView(gesture : UITapGestureRecognizer) {
//        postVC.textView.text = ""
//        postVC.wordCountLabel.text = "140 Twitter, 63206 Facebook"
//        postVC.sendBtn.isEnabled = false
        postVC.view.subviews.last?.removeFromSuperview()
        postVC = nil
    }
    


    func sendDataFilter(text: String, images: [HAImage], video: [HAVideo], presentFrom: HAPostController){
        postVC = presentFrom
        let twitterMgr = HATwitterManager()

        if text.characters.count != 0 && images.count == 0  && video.count == 0{// text Only
            
            var hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: "Uploading", onlyOneError: false)
            postVC.view.addSubview(hudEffectView)
            
            twitterMgr.sendTweetWithTextOnly(text: text, completion: { [weak self] (errorMessage) in
                let twitterErrorMsg = errorMessage

                let facebookMgr = HAFacebookManager()
                facebookMgr.sendTextOnly(text: text, completion: { (errorMessage) in
                    self?.postVC.view.subviews.last?.removeFromSuperview()//delete outdated HUD
                    
                    //FIXME: 在这几个判断里将Post将发帖数量更新并写入plist文件
                    if twitterErrorMsg == nil && errorMessage == nil {// error free
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: "Success", onlyOneError: false)
                        
                        self?.postVC.textView.text = ""
                        self?.postVC.wordCountLabel.text = "140 Twitter, 63206 Facebook"
                        self?.postVC.sendBtn.isEnabled = false

                        if platforms.count == 2 {
                            (UIApplication.shared.delegate as! AppDelegate).writePostHelperAdvanturePlistInfo(totalPostOnAllPlatforms: 2, FbPostImageCount: 0, FbPostVideoCount: 0, TwPostImageCount: 0, TwPostVideoCount: 0)
                        } else {
                            (UIApplication.shared.delegate as! AppDelegate).writePostHelperAdvanturePlistInfo(totalPostOnAllPlatforms: 1, FbPostImageCount: 0, FbPostVideoCount: 0, TwPostImageCount: 0, TwPostVideoCount: 0)
                        }
                        
                    } else if twitterErrorMsg == nil && errorMessage != nil{//facebook error only
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: errorMessage!, onlyOneError: true)
                        (UIApplication.shared.delegate as! AppDelegate).writePostHelperAdvanturePlistInfo(totalPostOnAllPlatforms: 1, FbPostImageCount: 0, FbPostVideoCount: 0, TwPostImageCount: 0, TwPostVideoCount: 0)
                        
                    } else if twitterErrorMsg != nil && errorMessage == nil{//twitter error only
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: twitterErrorMsg!, onlyOneError: true)
                        (UIApplication.shared.delegate as! AppDelegate).writePostHelperAdvanturePlistInfo(totalPostOnAllPlatforms: 1, FbPostImageCount: 0, FbPostVideoCount: 0, TwPostImageCount: 0, TwPostVideoCount: 0)

                    } else {// both have error
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: twitterErrorMsg! + "\n" + errorMessage!, onlyOneError: false)
                    }
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAPostVCManager.tapOnBlurView(gesture:)))
                    hudEffectView.addGestureRecognizer(tapGesture)
                    
                    self?.postVC.view.addSubview(hudEffectView)//Add updated HUD
                    print("facebookMgr.sendTextOnly block end")

                })
                print("twitterMgr.sendTweetWithTextOnly block end")
            })
            
        } else if images.count != 0 && video.count == 0 {// image Only, text?
            
            postHUDFiter(imagesCount: images.count, videoCount: video.count, presentController: postVC)
            
            twitterMgr.sendTweetWithTextandImages(images: images, text: text, completion: { (error) in
                let facebookMgr = HAFacebookManager()
                facebookMgr.sendGroupPhotos(images: images, text: text, completion: { (error) in
                })
            })
            
        } else if images.count == 0 && video.count != 0 {// video Only, text?
            
            postHUDFiter(imagesCount: images.count, videoCount: video.count, presentController: postVC)

            twitterMgr.sendTweetWithTextandVideo(video: video[0], text: text, completion: { (error) in
                let facebookMgr = HAFacebookManager()
                facebookMgr.FB_SendVideoOnly(avAssetsForSend: video[0], text: text, completion: { (error) in
                    
                })
            })
            
        } else if images.count > 0 && video.count > 0 {// image + video, text?
            
            postHUDFiter(imagesCount: images.count, videoCount: video.count, presentController: postVC)

            let currentQ = DispatchQueue(label: "currentQForImageAndVideo", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
            let facebookMgr = HAFacebookManager()
            currentQ.async {
                twitterMgr.sendTweetWithTextandImages(images: images, text: text, completion: { (error) in
                    facebookMgr.sendGroupPhotos(images: images, text: text, completion: { (error) in
                    })

                })
            }
            currentQ.async {
                twitterMgr.sendTweetWithTextandVideo(video: video[0], text: text, completion: { (error) in
                    facebookMgr.FB_SendVideoOnly(avAssetsForSend: video[0], text: text, completion: { (error) in
                        
                    })

                })
            }
        }
    }
    
    func postHUDFiter(imagesCount: Int, videoCount: Int, presentController : HAPostController) {
        
        
        let sb = UIStoryboard(name: "HAUploadStatusController", bundle: nil)
        guard let uploadStatusViewController = sb.instantiateInitialViewController() else {
            return
        }
        let uploadVC = uploadStatusViewController as! HAUploadStatusController
        uploadVC.imagesCount = imagesCount
        uploadVC.videoCount = videoCount
        uploadVC.postVC = presentController
        if platforms.count == 2 {
            uploadVC.FBBaseVewIsHidden = false
            uploadVC.TWBaseVewIsHidden = false

        } else if platforms.contains(.HATwitter) && platforms.count == 1 {
            uploadVC.FBBaseVewIsHidden = true
//            uploadVC.FBBaseView.isHidden = true
            
        } else if platforms.contains(.HAFacebook) && platforms.count == 1 {
            uploadVC.TWBaseVewIsHidden = true
//            uploadVC.TWBaseView.isHidden = true
            
        } else { //platforms.count == 0
            return
        }
        
//        presentController.view.addSubview(<#T##view: UIView##UIView#>)
//        presentController.present(popVC, animated: true, completion: nil)
        
        let currentRootVc = UIApplication.shared.keyWindow?.rootViewController
        uploadVC.currentRootVc = currentRootVc
        UIApplication.shared.keyWindow?.rootViewController = uploadVC

//        print("\( UIApplication.shared.keyWindow?.rootViewController)")
    }
    
    
    func HA_attributedText (text: String, textColor: UIColor?, rangeForTextColor: NSRange?) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: text)
        
        if textColor != nil {
            attributeString.addAttribute(NSForegroundColorAttributeName, value: textColor!, range: rangeForTextColor!)
        }
        
        
        attributeString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 14), range: rangeForTextColor!)

        return attributeString
    }
    
    
    
    func HA_switchSelectedPlatformImage(button: UIButton) {
        
    }
    
    

    func getCurrentNetworkStatus () -> String{
        let app = UIApplication.shared
        let a =  app.value(forKeyPath: "statusBar") as! UIView
        let b = a.value(forKeyPath: "foregroundView") as! UIView
        var status = ""
        var netType = 0
        
        for child in b.subviews {
            if child.isKind(of: NSClassFromString("UIStatusBarDataNetworkItemView")!) {
               let number = child.value(forKeyPath: "dataNetworkType") as! NSNumber
               netType = number.intValue
            }
        }
        
        switch netType {
        case 0:
            status = "no network"
            break
//        case 1:
//            status = "2G"
//            break
//        case 2:
//            status = "3G"
//            break
//        case 3:
//            status = "4G"
//            break
//        case 4:
//            status = "LTE-4G"
//            break
        case 5:
            status = "WIFI"
            break
        default:
            break
        }
        
        return status
    }
    
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
}

extension HAPostVCManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HAPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    
}


extension HAPostVCManager: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresented ? animateTransitionForPresent(transitionContext: transitionContext) : animateTransitionForDismiss(transitionContext: transitionContext)
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

