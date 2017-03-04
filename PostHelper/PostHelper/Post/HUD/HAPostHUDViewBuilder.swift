//
//  HAPostHUDView.swift
//  PostHelper
//
//  Created by LONG MA on 22/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAPostHUDViewBuilder : NSObject {
    
    class func createSendTextOnlyHUD(textInView: String, onlyOneError: Bool) -> UIVisualEffectView{
        
        let ringforText = M13ProgressViewRing(frame: CGRect(x: UIScreen.main.bounds.size.width * 0.5 - 30, y: UIScreen.main.bounds.size.height * 0.5 - 100, width: 60, height:60))
        
        if textInView == "Success" {
            ringforText.primaryColor = UIColor.green
            ringforText.secondaryColor = UIColor.green
            ringforText.indeterminate = false
            ringforText.showPercentage = false
            ringforText.perform(M13ProgressViewActionSuccess, animated: true)

        } else if textInView == "Uploading"{
            ringforText.indeterminate = true
            ringforText.showPercentage = false
            ringforText.primaryColor = UIColor.white
            ringforText.secondaryColor = UIColor.white
            
        } else if onlyOneError == true {
            ringforText.primaryColor = UIColor.yellow
            ringforText.secondaryColor = UIColor.yellow
            ringforText.indeterminate = false
            ringforText.showPercentage = false
            ringforText.perform(M13ProgressViewActionFailure, animated: true)

        } else {// Both Failure
            ringforText.primaryColor = UIColor.red
            ringforText.secondaryColor = UIColor.red
            ringforText.indeterminate = false
            ringforText.showPercentage = false
            ringforText.perform(M13ProgressViewActionFailure, animated: true)
            
        }
        
        let effectView = createBlurView()
        effectView.contentView.addSubview(ringforText)
        
        if textInView != "" {
            let label = UILabel(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height * 0.5 - 40, width: UIScreen.main.bounds.size.width, height: 100))
            label.text = textInView
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = false
            effectView.contentView.addSubview(label)

            
            if textInView != "Uploading" {
                let dismisslabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width * 0.5 - 80, y: UIScreen.main.bounds.size.height - 100, width: 160, height: 60))
                dismisslabel.adjustsFontSizeToFitWidth = false
                dismisslabel.text = "Tap to dismiss"
                dismisslabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
                dismisslabel.textAlignment = .center
                dismisslabel.textColor = UIColor.white
                dismisslabel.textAlignment = .center
                dismisslabel.numberOfLines = 0
                effectView.contentView.addSubview(dismisslabel)

            }
            
            
            
            
        }
        
        return effectView
}
    
   internal class func createBlurView() -> UIVisualEffectView{
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.frame = UIScreen.main.bounds
        effectView.alpha = 0.8

        return effectView
    }
        
    
}
