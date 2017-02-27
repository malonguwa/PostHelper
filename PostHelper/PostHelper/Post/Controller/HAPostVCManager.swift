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
                    if twitterErrorMsg == nil && errorMessage == nil {// error free
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: "Success", onlyOneError: false)
                    } else if twitterErrorMsg == nil && errorMessage != nil{//facebook error only
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: errorMessage!, onlyOneError: true)
                    } else if twitterErrorMsg != nil && errorMessage == nil{//twitter error only
                        hudEffectView = HAPostHUDViewBuilder.createSendTextOnlyHUD(textInView: twitterErrorMsg!, onlyOneError: true)
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
            twitterMgr.sendTweetWithTextandImages(images: images, text: text, sendToPlatforms: platforms, completion: { (error) in
                
            })
            
        } else if images.count == 0 && video.count != 0 {// video Only, text?
            twitterMgr.sendTweetWithTextandVideo(video: video[0], text: text, sendToPlatforms: platforms, completion: { (error) in
                
            })
            
        } else if images.count > 0 && video.count > 0 {// image + video, text?
            let currentQ = DispatchQueue(label: "currentQForImageAndVideo", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
            currentQ.async {
                twitterMgr.sendTweetWithTextandImages(images: images, text: text, sendToPlatforms: platforms, completion: { (error) in
                    
                })
            }
            currentQ.async {
                twitterMgr.sendTweetWithTextandVideo(video: video[0], text: text, sendToPlatforms: platforms, completion: { (error) in
                    
                })
            }
            
        }
        
        
        
        
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

