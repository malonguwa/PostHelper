//
//  HAPostVCManager.swift
//  PostHelper
//
//  Created by LONG MA on 16/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation


//enum WhichButton {
//    case Pic
//    case Video
//}

class HAPostVCManager: NSObject {

    fileprivate lazy var isPresented : Bool = false

    func HA_attributedText (textView: UITextView, textBgColor: UIColor?, rangeForBgColor: NSRange?) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: textView.text)
        
        if textBgColor != nil {
            attributeString.addAttribute(NSBackgroundColorAttributeName, value: textBgColor!, range: rangeForBgColor!)
        }
        
        attributeString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, attributeString.length))

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

