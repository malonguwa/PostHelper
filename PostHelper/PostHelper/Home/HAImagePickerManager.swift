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
    var HnA_selectedAVAssets : ((_ combinedArray : [DKAsset]) -> ())?
    
//    var HnA_updatedImages = [DKAsset]()
//    var HnA_updatedVideos = [DKAsset]()

    //selectedImagesArray + selectedVideosArray = combinedArray
    var selectedImagesArray = [DKAsset]()
    var selectedVideosArray = [DKAsset]()
    
    var deselectedImagesAssets = [DKAsset]()
    var deselectedVideosAssets = [DKAsset]()

    // mutableArray for selected images
//    var imageArray : [UIImage] = [UIImage]()

    
    ///MARK: Pop up image picker controller - attach image(s)
    func addImage(naviController : UIViewController) {
        print("1 addImage \(selectedImagesArray.count)")
        print("1 addImage \(selectedVideosArray.count)")
        let imagePickerController = DKImagePickerController()
//        self.imagePickerController = imagePickerController
        print("image: \(imagePickerController)")
        imagePickerController.assetType = .allPhotos
        imagePickerController.maxSelectableCount = 9
        imagePickerController.showsCancelButton = true
        
        if (selectedImagesArray.count == 0){
            print("1 selectedImagesArray.count: \(selectedImagesArray.count)")
            imagePickerController.selectedAssets = selectedImagesArray
            print("2 selectedImagesArray.count: \(selectedImagesArray.count)")
        }
//        else if HnA_updatedImages?.count == 0 && selectedImagesArray.count > 0{
//            imagePickerController.selectedAssets = HnA_updatedImages!
////            selectedImagesArray = HnA_updatedImages!
//        }
        else {
            imagePickerController.selectedAssets = selectedImagesArray
        }
        print("2 addImage \(selectedImagesArray.count)")
        print("2 addImage \(selectedVideosArray.count)")
        
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
            var combinedArray = [DKAsset]()
            combinedArray.append(contentsOf: self.selectedImagesArray)
//            print("combinedArray.append : \(self.selectedImagesArray)")
            combinedArray.append(contentsOf: self.selectedVideosArray)
            _selectedImages(combinedArray)
        }
        print("combinedArray.append : \(self.selectedImagesArray)")

        naviController.present(imagePickerController, animated: true, completion: nil)
    }
    
    ///MARK: Pop up video picker controller - attach video(s)
    func addVideo(naviController : UIViewController) {
         let videoPickerController = DKImagePickerController()
        print("video: \(videoPickerController)")
        videoPickerController.assetType = .allVideos
        videoPickerController.maxSelectableCount = 4
        print("maxSelectableCount: \(videoPickerController.maxSelectableCount)")
        videoPickerController.showsCancelButton = true
        

        

        if selectedVideosArray.count == 0 {
            videoPickerController.selectedAssets = selectedVideosArray
            print("HnA_deselectedAVAssets == nil  Closure")
        } else {
            videoPickerController.selectedAssets = selectedVideosArray
        }
        
        
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
                print("selectedVideos = nil")
                return
            }
            
            var combinedArray = [DKAsset]()
            combinedArray.append(contentsOf: self.selectedImagesArray)
            combinedArray.append(contentsOf: self.selectedVideosArray)
            _selectedVideos(combinedArray)
        }
        
        naviController.present(videoPickerController, animated: true, completion: nil)
    }
    
    deinit {
        print("HAImagePickerManager deinit")
    }
}
