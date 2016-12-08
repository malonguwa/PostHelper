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
    var HnA_selectedAVAssets : ((_ HnA_DKAssetArray : [DKAsset]) -> ())?
    // mutableArray for selected images
//    var imageArray : [UIImage] = [UIImage]()

    //TODO:todo 2.addImage 和  addVideo 优化
    //TODO:todo 3.addVideo-当选择后截第一帧

    ///MARK: attach image(s)
    func addImage(naviController : UIViewController) {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos

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
            
            guard let _selectedImages = self.HnA_selectedAVAssets else {
                print("selectedImages = nil")
                return
            }
            _selectedImages(assets) 
        }
        
        naviController.present(pickerController, animated: true, completion: nil)
        
    }
    
    ///MARK: attach video
    func addVideo(naviController : UIViewController) {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allVideos
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
            
            guard let _selectedVideos = self.HnA_selectedAVAssets else {
                print("selectedImages = nil")
                return
            }
            _selectedVideos(assets)
        }
        
        naviController.present(pickerController, animated: true, completion: nil)

        
        
    }
    
    
}
