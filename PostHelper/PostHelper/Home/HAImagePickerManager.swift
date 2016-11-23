//
//  HAImagePickerTool.swift
//  PostHelper
//
//  Created by LONG MA on 23/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit

class HAImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var callBack : (() -> ())?
    
    
    // mutableArray for selected images
    var imageArray : [UIImage] = [UIImage]()
    
    
    func addImage(naviController : UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        naviController.present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    // MARK: Delegate - UIImagePickerControllerDelegate
    /// select photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageArray.append(image)
        
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            guard let callBack = self.callBack else {
                print("callback = nil")
                return
            }
            print("callback != nil")
            callBack()
            print("picker dismiss")
        })
    }
    
    
    
    // MARK: Delegate - UINavigationControllerDelegate

    
}
