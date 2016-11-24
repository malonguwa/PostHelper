//
//  HAImagePickerTool.swift
//  PostHelper
//
//  Created by LONG MA on 23/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit 
import DKImagePickerController

class HAImagePickerManager: NSObject {

    // closure for HAPostVC.textViewDidChange
    var callBack : (() -> ())?
    // closure for add images in scrollView
    var selectedImages : ((_ imageArray : [DKAsset]) -> ())?
    // mutableArray for selected images
//    var imageArray : [UIImage] = [UIImage]()
    
    
    func addImage(naviController : UIViewController) {
        let pickerController = DKImagePickerController()
        
        // when click cancel button
        pickerController.didCancel = {
            guard let _callBack = self.callBack else {
                print("callback = nil")
                return
            }
            _callBack()
        }
        
        // when click select button
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            guard let _selectedImages = self.selectedImages else {
                print("selectedImages = nil")
                return
            }
            _selectedImages(assets) 
        }
        
        naviController.present(pickerController, animated: true, completion: nil)
        
    }
}
