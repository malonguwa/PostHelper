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
    
    
    weak var currentRootVc: UIViewController!
    var TWBaseVewIsHidden: Bool = false
    var FBBaseVewIsHidden: Bool = false

    override func viewDidLoad() {
        
        TWBaseView.isHidden = TWBaseVewIsHidden
        FBBaseView.isHidden = FBBaseVewIsHidden
        
        view.insertSubview(HAPostHUDViewBuilder.createBlurView(), at: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HAUploadStatusController.tapOnBlurView(gesture:)))
        view.subviews[0].addGestureRecognizer(tapGesture)

        setUpRingView()
    }
    
    
    func setUpRingView() {
        let ringforFB = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ringforFB.indeterminate = true
        FBRingView.insertSubview(ringforFB, at: 0)
        
        let ringforTW = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        ringforTW.indeterminate = true
//        ringforTW.backgroundRingWidth = 5
//        ringforTW.primaryColor = UIColor.white
//        ringforTW.backgroundColor = UIColor.white
//        ringforTW.tintColor = UIColor.white
        ringforTW.secondaryColor = UIColor.white
        TWRingView.insertSubview(ringforTW, at: 0)
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


