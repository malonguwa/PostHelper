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

//    var imagePickerController = DKImagePickerController()
//    var videoPickerController = DKImagePickerController()
    
    
    // closure for HAPostVC.textViewDidChange
    var callBack : (() -> ())?
    // closure for add images in scrollView
    var HnA_selectedAVAssets : ((_ HnA_DKAssetArray : [DKAsset]) -> ())?
    var selectedImagesArray = [DKAsset]()
    var selectedVideosArray = [DKAsset]()
    
    
    // mutableArray for selected images
//    var imageArray : [UIImage] = [UIImage]()

    
    ///MARK: Pop up image picker controller - attach image(s)
    func addImage(naviController : UIViewController) {
        let imagePickerController = DKImagePickerController()
//        self.imagePickerController = imagePickerController
        print("image: \(imagePickerController)")
        imagePickerController.assetType = .allPhotos
        imagePickerController.maxSelectableCount = 9
        imagePickerController.showsCancelButton = true
        imagePickerController.selectedAssets = selectedImagesArray
        // when click cancel button
        imagePickerController.didCancel = {
            guard let _callBack = self.callBack else {
                print("callback = nil")
                return
            }
            _callBack()
        }
        
        // when click select button
        imagePickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            self.selectedImagesArray = assets

            guard let _selectedImages = self.HnA_selectedAVAssets else {
                print("selectedImages = nil")
                return
            }
            _selectedImages(assets)
        }
        
        naviController.present(imagePickerController, animated: true, completion: nil)
    }
    
    ///MARK: Pop up video picker controller - attach video(s)
    func addVideo(naviController : UIViewController) {
         let videoPickerController = DKImagePickerController()
//        self.videoPickerController = videoPickerController
        print("video: \(videoPickerController)")
        videoPickerController.assetType = .allVideos
        videoPickerController.maxSelectableCount = 4
        print("maxSelectableCount: \(videoPickerController.maxSelectableCount)")
        videoPickerController.showsCancelButton = true
        videoPickerController.selectedAssets = selectedVideosArray
        print("videoPickerController.selectedAssets : \(videoPickerController.selectedAssets.count)")
        // when click cancel button
        videoPickerController.didCancel = {
            guard let _callBack = self.callBack else {
                print("callback = nil")
                return
            }
            _callBack()
        }
        
        // when click select button
        videoPickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print("\(assets.count)")
            
            self.selectedVideosArray = assets
            guard let _selectedVideos = self.HnA_selectedAVAssets else {
                print("selectedImages = nil")
                return
            }
            
            
            _selectedVideos(assets)
        }
        
        naviController.present(videoPickerController, animated: true, completion: nil)
    }
    
    deinit {
        print("HAImagePickerManager deinit")
    }
}
