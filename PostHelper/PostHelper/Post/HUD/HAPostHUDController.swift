//
//  HAPostHUDController.swift
//  PostHelper
//
//  Created by LONG MA on 22/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAPostHUDController : UIViewController {

    var textInHUD : String = ""
    
    override func viewDidLoad() {
        addSendTextOnlyHUD(textInView: textInHUD)
    }
    
    func addSendTextOnlyHUD(textInView: String) {
        
        let ringforText = M13ProgressViewRing(frame: CGRect(x: UIScreen.main.bounds.size.width * 0.5 - 40, y: UIScreen.main.bounds.size.height * 0.5 - 70, width: 80, height:80))
        ringforText.indeterminate = true
        ringforText.showPercentage = false
        //            ringforText.primaryColor = UIColor(colorLiteralRed: 0.00, green: 162.00, blue: 236.00, alpha: 1)
        ringforText.primaryColor = UIColor.white
        ringforText.secondaryColor = UIColor.white

        
        let effectView = createBlurView()
        effectView.contentView.addSubview(ringforText)
        
        
        if textInView != "" {
            let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width * 0.5 - 50, y: UIScreen.main.bounds.size.height * 0.5 - 40, width: 100, height: 80))
            label.text = textInView//"Uploading"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            label.textAlignment = .center
            label.textColor = UIColor.white
            effectView.contentView.addSubview(label)
        }
        
        view.addSubview(effectView)
    }
    
    func createBlurView() -> UIVisualEffectView{
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.frame = UIScreen.main.bounds
        effectView.alpha = 0.8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAPostHUDController.tapOnBlurView(gesture:)))
        effectView.addGestureRecognizer(tapGesture)

        return effectView
    }
    
    //MARK: TapGesture
    func tapOnBlurView(gesture : UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    
}
