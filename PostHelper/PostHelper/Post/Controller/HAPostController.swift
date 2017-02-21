//
//  HAPostController.swift
//  PostHelper
//
//  Created by LONG MA on 16/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit

class HAPostController: UIViewController  {
    
    var videoInGalleryArray : [HAVideo]!
    var imageInGalleryArray : [HAImage]!
    var arrayForDisplay : [UIImage] = [UIImage]()
    var wordCountLabel : UILabel!
    var postVCMgr : HAPostVCManager = HAPostVCManager()
    var TwitterWordCount = 0
    var selected_assets = NSMutableArray()
    var selected_TZModels = NSMutableArray()
    var wordCountLabelMove = true

    //    lazy var picVC : TZImagePickerController = {
    //        return TZImagePickerController(maxImagesCount: 9, delegate: self)
    //    }()
    //
    //    lazy var videoVC : TZImagePickerController = {
    //        return TZImagePickerController(maxImagesCount: 1, delegate: self)
    //    }()
    @IBOutlet weak var platformSelectionBtn: UIButton!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var galleryArrowBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    

    
    override func viewDidLoad() {
        textView.becomeFirstResponder()
        videoInGalleryArray = [HAVideo]()
        imageInGalleryArray = [HAImage]()
        setUpWordCountLabel()
        textView.delegate = self
//        postVCMgr.HA_switchSelectedPlatformImage(button: <#T##UIButton#>)
        NotificationCenter.default.addObserver(self, selector:#selector(HAPostController.keyboardWillChange(notice :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        HAPlatformSelectionController.switchPlatformImage(button: platformSelectionBtn)
    }
    

    // MARK: Notification - UIKeyboardWillChangeFrame
    func keyboardWillChange(notice : Notification) {
        let value = notice.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let frame = value.cgRectValue
        let height = UIScreen.main.bounds.height
        let offsetY = height - frame.origin.y
        let duration = notice.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        toolBarBottomConstraint.constant = offsetY
        UIView.animate(withDuration: duration, animations:{ () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    
    //MARK: setUpWordCountLabel
    func setUpWordCountLabel() {
        let wordCountLabel_H = CGFloat(18.0)
        let wordCountLabel_W = view.frame.size.width
        let wordCountLabel_X = CGFloat(0.0)
        let wordCountLabel_Y = CGFloat(textView.frame.size.height) + wordCountLabel_H + 28
        wordCountLabel = UILabel.init()
        wordCountLabel = UILabel(frame: CGRect(x: wordCountLabel_X, y: wordCountLabel_Y, width: wordCountLabel_W, height: wordCountLabel_H))
        wordCountLabel.font = UIFont.systemFont(ofSize: 12.0)
        wordCountLabel.textColor = UIColor.gray
        wordCountLabel.text = "\(140 - TwitterWordCount) Twitter, \(63206 - TwitterWordCount) Facebook"
        wordCountLabel.backgroundColor = UIColor.white
        view.insertSubview(wordCountLabel, at: view.subviews.count - 3)
    }
    
    
    //MARK: showWordCountLimit
    func placeWordCountLimit() {
        
        if galleryArrowBtn.isHidden == false {//Up
            
            if galleryArrowBtn.isSelected == false {//Up
                print("hideScrollViewBtn.isSelected == false")
                wordCountLabel.alpha = 0
                if self.wordCountLabel.frame.origin.y == 142 {
                    UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.wordCountLabel.frame.origin = CGPoint(x: 0, y: 248)
                        self.wordCountLabel.alpha = 1
                        
                        self.wordCountLabel.superview?.layoutIfNeeded()
                    })
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.wordCountLabel.frame.origin = CGPoint(x: 0, y: 142)
                        self.wordCountLabel.alpha = 1
                        
                        self.wordCountLabel.superview?.layoutIfNeeded()
                    })
                    
                }
                
            } else if galleryArrowBtn.isSelected == true{//Down
                print("hideScrollViewBtn.isSelected == true")
                
                wordCountLabel.alpha = 0
                
                if self.wordCountLabel.frame.origin.y == 248 {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.wordCountLabel.frame.origin = CGPoint(x: 0, y: 142)
                        self.wordCountLabel.alpha = 1
                        self.wordCountLabel.superview?.layoutIfNeeded()
                    })
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.wordCountLabel.frame.origin = CGPoint(x: 0, y: 248)
                        self.wordCountLabel.alpha = 1
                        self.wordCountLabel.superview?.layoutIfNeeded()
                        
                    }, completion: nil)
                }
            }
        } else {//Down
            UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                print("hideScrollViewBtn.isHidden == true")
                self.wordCountLabel.frame.origin = CGPoint(x: 0, y: 248)
                self.wordCountLabel.superview?.layoutIfNeeded()
            })
        }
    }
    
    // MARK: Button - add image and delete Btn on gallery
    func addImageAndDeleteBtnOnGallery(image: UIImage, offset: Int) {
        
        let HAimageView = UIImageView(image: image)
        HAimageView.frame = CGRect(x: (offset * 100) + 10 * offset, y: 0, width: 100, height: 90)
        HAimageView.backgroundColor = UIColor.black
        let color = HAimageView.backgroundColor?.withAlphaComponent(0.8)
        HAimageView.backgroundColor = color
        HAimageView.isUserInteractionEnabled = true
        HAimageView.contentMode = UIViewContentMode.scaleAspectFit
//        HAimageView.layer.borderWidth = 2.0
//        HAimageView.layer.borderColor = UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0).cgColor
        let deleteBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deleteBtn.setImage(UIImage(named: "deletimage"), for: UIControlState.normal)
        deleteBtn.tag = offset
        contentView.addSubview(HAimageView)
        
        HAimageView.addSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(HAPostController.deleteImageInScrollView(_:)), for: UIControlEvents.touchUpInside)
        

        let count = self.imageInGalleryArray.count + self.videoInGalleryArray.count
        if offset == count - 1 {
            DispatchQueue.main.async(){ [weak self] in
                self?.contentViewWidthConstraint.constant = CGFloat((count * 100) + (20 * count))
                self?.scrollView.setNeedsLayout()
                self?.scrollView.setNeedsDisplay()
            }
        }

        
        
    }
    
    // MARK: UIButton Action - delete button cick on gallery image
    func deleteImageInScrollView(_ sender: UIButton) {
        if sender.tag == imageInGalleryArray.count {
            videoInGalleryArray.removeAll()
        } else {
            imageInGalleryArray.remove(at: sender.tag)
            selected_assets.removeObject(at: sender.tag)
        }
        
        if imageInGalleryArray.count > 0 || videoInGalleryArray.count > 0 {
            self.sendBtn.isEnabled = true
        } else if textView.text.lengthOfBytes(using: .utf8) == 0 && imageInGalleryArray.count == 0 && videoInGalleryArray.count == 0{
            self.sendBtn.isEnabled = false
        }
        
        if imageInGalleryArray.count == 0 && videoInGalleryArray.count == 0 {
            scrollView.isHidden = true
            galleryArrowBtn.isHidden = true
            placeWordCountLimit()
            wordCountLabelMove = !wordCountLabelMove
        } else {
            arrayForDisplay.remove(at: sender.tag)
            reloadScrollViewImages()
        }
    }

    internal func reloadScrollViewImages() {
        
        wordCountLabelMove = !wordCountLabelMove

        for delete in contentView.subviews{
            delete.removeFromSuperview()
        }
        
        for image in arrayForDisplay.enumerated() {
            addImageAndDeleteBtnOnGallery(image: image.element, offset: image.offset)
        }
        
        HAPlatformSelectionController.disableSendBtn(sendBtn: sendBtn, displayCount: arrayForDisplay.count)

    }
    
    //MARK: UIButton Linked Actions
    
    @IBAction func clickGalleryArrow(_ sender: UIButton) {
        if sender.isSelected == true {//show
            self.placeWordCountLimit()
            UIView.animate(withDuration: 0.5, animations: {
                print("show")
                
                self.galleryArrowBtn.transform = CGAffineTransform(rotationAngle: 0.0)
                self.contentView.superview?.transform = (self.contentView.superview?.transform.translatedBy(x: -(self.contentView.superview?.transform.tx)!, y: (self.contentView.superview?.transform.ty)!))!
            }, completion: nil)
            sender.isSelected = false
        } else {//hide
            self.placeWordCountLimit()
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                print("hide")
                self.galleryArrowBtn.transform = self.scrollView.transform.rotated(by: CGFloat(M_PI-0.000001))
                
                self.contentView.superview?.transform = (self.contentView.superview?.transform.translatedBy(x: (self.contentView.superview?.transform.tx)! + UIScreen.main.bounds.width, y: (self.contentView.superview?.transform.ty)!))!
            }, completion: nil)
            sender.isSelected = true
        }

    }

    
    @IBAction func clickpic(_ sender: Any) {
        let picVC = TZImagePickerController(maxImagesCount: 9, delegate: self)!
        picVC.selectedAssets = selected_assets
        picVC.allowPickingGif = false
        picVC.allowPickingVideo = false
        picVC.allowPickingOriginalPhoto = false
        picVC.allowTakePicture = false
        present(picVC, animated: true, completion: nil)
    }
    
    @IBAction func clickvideo(_ sender: Any) {
        
        let videoVC = TZImagePickerController(maxImagesCount: 1, delegate: self)!
        videoVC.allowCrop = true
        videoVC.allowPickingGif = false
        videoVC.allowPickingImage = false
        videoVC.allowTakePicture = false
        present(videoVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func clickPlatformSelectionBtn(_ sender: UIButton) {
        let sb = UIStoryboard(name: "HAPlatformSelectionController", bundle: nil)
        guard let popoverMenuViewController = sb.instantiateInitialViewController() else {
            return
        }
        let popVC = popoverMenuViewController as! HAPlatformSelectionController
        popVC.transitioningDelegate = postVCMgr
        popVC.modalPresentationStyle = .custom
        popVC.platformBtn = platformSelectionBtn
        popVC.sendDisableBtn = sendBtn
        popVC.displayArrayCount = arrayForDisplay.count
        present(popVC, animated: true, completion: nil)
    }
    

    @IBAction func dismissBtn(_ sender: Any) {
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("HAPostController deinit")
    }

    
}

extension HAPostController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        if photos.count > 0 && videoInGalleryArray.count == 0{
            scrollView.isHidden = false
            galleryArrowBtn.isHidden = false
            if  wordCountLabelMove == true{
                placeWordCountLimit()
            }
            sendBtn.isEnabled = true
        }

        if isSelectOriginalPhoto == false {
            imageInGalleryArray.removeAll()
            arrayForDisplay.removeAll()
            selected_assets.removeAllObjects()
            selected_assets = NSMutableArray(array: assets)
            
            for photo in photos.enumerated() {
                let HAimage = HAImage(image: photo.element)
                imageInGalleryArray.append(HAimage)
                arrayForDisplay.append(photo.element)
            }
            
            if videoInGalleryArray.count > 0 {
                arrayForDisplay.append(videoInGalleryArray[0].HAvideoImage!)
            }

//            wordCountLabelMove = !wordCountLabelMove
            reloadScrollViewImages()

        }
        
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: Any!) {
        TZImageManager.default().getVideoWithAsset(asset) { [weak self] (AVPlayerItem, info) in
            DispatchQueue.main.async {
                if self?.imageInGalleryArray.count == 0 {
                    self?.scrollView.isHidden = false
                    self?.galleryArrowBtn.isHidden = false
                    if  self?.wordCountLabelMove == true{
                        self?.placeWordCountLimit()
                    }
                    self?.sendBtn.isEnabled = true
                }
                
                let videoModel = HAVideo.init(avPlayerItem: AVPlayerItem!, coverImage: coverImage)
                videoModel.printInfo()
                self?.videoInGalleryArray?.removeAll()
                self?.arrayForDisplay.removeAll()
                self?.videoInGalleryArray?.append(videoModel)
                self?.arrayForDisplay.append(coverImage)
                
                if (self?.imageInGalleryArray.count)! > 0 {
                    for image in (self?.imageInGalleryArray.enumerated())! {
                        self?.arrayForDisplay.insert(image.element.HAimage!, at: image.offset)
                    }
                }
            
//                self?.wordCountLabelMove = !(self?.wordCountLabelMove)!
                self?.reloadScrollViewImages()
            }
        }
    }

    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
    }
    
}

// MARK: UITextViewDelegate
extension HAPostController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.becomeFirstResponder()
        let currentRange = textView.selectedRange
        
        if textView.text.lengthOfBytes(using: .utf8) > 0{
            TwitterWordCount = textView.text.lengthOfBytes(using: .utf8)
            sendBtn.isEnabled = true
            placeHolderLabel.isHidden = true
            
            
        } else if arrayForDisplay.count == 0 && textView.text.lengthOfBytes(using: .utf8) == 0{
            TwitterWordCount = 0
            sendBtn.isEnabled = false
            placeHolderLabel.isHidden = false
        } else if textView.text.lengthOfBytes(using: .utf8) == 0 {
            TwitterWordCount = 0
        }
        else {
            TwitterWordCount = textView.text.lengthOfBytes(using: .utf8)
        }
        
        if textView.text.lengthOfBytes(using: .utf8) > 140{
            textView.attributedText = postVCMgr.HA_attributedText(textView: textView, textBgColor: UIColor.init(red: 0.0, green: 162.0, blue: 236.0, alpha: 0.2), rangeForBgColor: NSMakeRange(0, 140))
            
        }else {//<=140
            textView.attributedText = postVCMgr.HA_attributedText(textView: textView, textBgColor: nil, rangeForBgColor: nil)
        }
        
        wordCountLabel.text = "\(140 - TwitterWordCount) Twitter, \(63206 - TwitterWordCount) Facebook"
        textView.selectedRange = currentRange
    }
    
}
