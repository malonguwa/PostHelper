//
//  HAPresentationController.swift
//  PostHelper
//
//  Created by LONG MA on 18/1/17.
//  Copyright © 2017 HnA. All rights reserved.
//

class HAPresentationController: UIPresentationController {
    
    private lazy var coverView : UIView = UIView()
    
    
    //被modal出来的controller，添加在containerView上，这个方法用来改变modal出来的控制器的frame
    override func containerViewWillLayoutSubviews() {
        //1.设置frame
        presentedView?.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.5 - 90, y: 55, width: 180, height: 250)
        //2.设置HUD
        setupCoverView()
    }
    
    /// MARK: HUD for coverView
    private func setupCoverView() {
        //1.添加HUD
        containerView?.insertSubview(coverView, at: 0)
        coverView.frame = containerView!.bounds
        //2.添加HUD手势
        coverView.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(HAPresentationController.coverViewClick))
        coverView.addGestureRecognizer(tapGr)
    }
    
    @objc private func coverViewClick(){
        presentedViewController.dismiss(animated: true) { 
            
        }
    }
    
    
}
