//
//  HAAnimationDelegate.swift
//  PostHelper
//
//  Created by LONG MA on 23/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAAnimationDelegate : NSObject, CAAnimationDelegate {
    
    weak var imageView : UIImageView!
    
    func animationDidStart(_ anim: CAAnimation) {
        print("animationDidStart")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
//        let image = UIImage.animatedImageNamed("red_dot_image", duration: 0.3)!
//        imageView.image = image
    }
    
    deinit {
        print("HAAnimationDelegate")
    }
}
