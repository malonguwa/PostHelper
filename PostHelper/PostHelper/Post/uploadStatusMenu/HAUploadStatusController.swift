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
    
    weak var currentRootVc: UIViewController!
    var TWBaseVewIsHidden: Bool = false
    var FBBaseVewIsHidden: Bool = false

    override func viewDidLoad() {
        
        TWBaseView.isHidden = TWBaseVewIsHidden
        FBBaseView.isHidden = FBBaseVewIsHidden
        
        view.insertSubview(HAPostHUDViewBuilder.createBlurView(), at: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
        view.subviews[0].addGestureRecognizer(tapGesture)

    }
    
    //MARK: TapGesture
    @objc fileprivate func tapOnBlurView(gesture : UITapGestureRecognizer) {
//        let RootVc = UIApplication.shared.keyWindow?.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = currentRootVc
    }

    
    
    deinit {
        print("HAUploadStatusController deinit")
    }
    
    
    
    
    
}


