//
//  HAPostController.swift
//  PostHelper
//
//  Created by LONG MA on 16/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit

class HAPostController: UIViewController, CAAnimationDelegate  {
    
    var videoInGalleryArray : [HAVideo]!
    var imageInGalleryArray : [HAImage]!
    var arrayForDisplay : [UIImage] = [UIImage]()
    var wordCountLabel : UILabel!
    var postVCMgr : HAPostVCManager = HAPostVCManager()
    var TwitterWordCount = 0
    var selected_assets = NSMutableArray()
    var selected_TZModels = NSMutableArray()
    var wordCountLabelMove = true
    var currentInputUnicodeScalarsCount = 0
    var lastTimeInputUnicodeScalarsCount = 0
    var limitInputUnicodeScalarsCount = 0
    var colorChangeRange = 0
    var sidePanelVC : HASidePanel?
//    var twitterMgr : HATwitterManager = HATwitterManager()
    
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
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    let image = UIImage.animatedImageNamed("dead0", duration: 0.2)
    var array = [UIImage]()
    lazy var coverView : UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.yellow
       return view
    }()
//    func HA_WillEnterForeground() {
//        textView.delegate = self
//        NotificationCenter.default.addObserver(self, selector:#selector(HAPostController.keyboardWillChange(notice :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//        
//        print("HA_WillEnterForeground")
//        
//    }
//
//    func HA_DidEnterBackground() {
//        textView.delegate = nil
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//        print("HA_DidEnterBackground")
//        
//    }
    
    
    func HA_fitScreen() {
        let screenHeight = UIScreen.main.bounds.height

        if screenHeight >= 667.0 {//iPhone 6,6+,6s,6s+,7,7+
            galleryArrowBtn.isHidden = true
            scrollViewTopConstraint.constant = CGFloat(textView.frame.size.height) + 18.0 + 28.0
            scrollView.backgroundColor = UIColor.clear
            contentView.backgroundColor = UIColor.clear
            view.layoutIfNeeded()
        } else { //iPhone 5, 5s, 5c, SE
            if scrollView.isHidden == false {
                galleryArrowBtn.isHidden = false
            }
        }
        
    }
    
    override func viewDidLoad() {
        array = Array.init((image?.images)!)
        textView.becomeFirstResponder()
        videoInGalleryArray = [HAVideo]()
        imageInGalleryArray = [HAImage]()
        textView.delegate = self
        setUpWordCountLabel()
        HA_fitScreen()
        NotificationCenter.default.addObserver(self, selector:#selector(HAPostController.keyboardWillChange(notice :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(HAPostController.HA_DidEnterBackground),
//                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
//                                               object: nil)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(HAPostController.HA_WillEnterForeground),
//                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
//                                               object: nil)

        
        HAPlatformSelectionController.switchPlatformImage(button: platformSelectionBtn)
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        print("viewWillAppear")
//    }
//
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        print("viewDidDisappear")
//
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppear")
//
//    }
    
    
    // MARK: Notification - UIKeyboardWillChangeFrame
    func keyboardWillChange(notice : Notification) {
        let value = notice.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let frame = value.cgRectValue
        let height = UIScreen.main.bounds.height
        let offsetY = height - frame.origin.y
        let duration = notice.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        toolBarBottomConstraint.constant = offsetY
        UIView.animate(withDuration: duration, animations:{ [weak self] () -> Void in
            self?.view.layoutIfNeeded()
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
//                print("hideScrollViewBtn.isSelected == true")
                
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
//                print("hideScrollViewBtn.isHidden == true")
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
        deleteBtn.setImage(UIImage(named: "deletimage2"), for: UIControlState.normal)
        deleteBtn.tag = offset
        deleteBtn.isExclusiveTouch = true
        contentView.addSubview(HAimageView)
        
        HAimageView.addSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(HAPostController.deleteImageInScrollView(_:)), for: UIControlEvents.touchUpInside)
        
        if videoInGalleryArray.count > 0 && offset == imageInGalleryArray.count{// video image need video label
            let videoLabelImageView = UIImageView(image: UIImage(named: "snow_video_64"))
            videoLabelImageView.frame = CGRect(x: 80, y: 70, width: 20, height: 20)
            HAimageView.addSubview(videoLabelImageView)
        }

        
        
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
        
        
        if sender.tag > arrayForDisplay.count - 1 {
            return
        }
        
        self.arrayForDisplay.remove(at: sender.tag)
        
        let imgView = sender.superview! as! UIImageView
        sender.removeFromSuperview()
        imgView.backgroundColor = UIColor.clear
        imgView.animationImages = array
        imgView.animationRepeatCount = 1
        imgView.animationDuration = 0.2

        UIView.animate(withDuration: 0.1, animations: {
            imgView.layer.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
        }) { (bool) in
//            self.deleteImageInScrollViewAfterAnimation(tag: sender.tag)

            imgView.image = nil
            
            imgView.startAnimating()
            
            let when = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                imgView.stopAnimating()
                imgView.animationImages = nil
                print("sender.tag---- \(sender.tag)")
                self.deleteImageInScrollViewAfterAnimation(tag: sender.tag)
                
            })
        }
    }
    
    
    internal func deleteImageInScrollViewAfterAnimation (tag: Int){
        
        // process image and video array for send
        if tag == imageInGalleryArray.count {
            videoInGalleryArray.removeAll()
            
        } else {
            imageInGalleryArray.remove(at: tag)
            selected_assets.removeObject(at: tag)
        }
        
        //process image array for display
        if imageInGalleryArray.count == 0 && videoInGalleryArray.count == 0{
            if arrayForDisplay.count != 0 {
                self.arrayForDisplay.removeAll()
            }
            scrollView.isHidden = true
            galleryArrowBtn.isHidden = true
            placeWordCountLimit()
            wordCountLabelMove = true
        } else {
//            self.arrayForDisplay.remove(at: tag)
            
            self.reloadScrollViewImages()
        }
        
        //sendBtn status change
        if imageInGalleryArray.count > 0 || videoInGalleryArray.count > 0 {
            sendBtn.isEnabled = true
        } else if self.textView.text.characters.count == 0 && imageInGalleryArray.count == 0 && videoInGalleryArray.count == 0{
            sendBtn.isEnabled = false
        }
        
    }

    internal func reloadScrollViewImages() {
        if arrayForDisplay.count == 0{
            wordCountLabelMove = !wordCountLabelMove
        }

        
        for delete in contentView.subviews{
            delete.removeFromSuperview()
        }
        
        for image in arrayForDisplay.enumerated() {
            addImageAndDeleteBtnOnGallery(image: image.element, offset: image.offset)
        }
        

        print("arrayForDisplay.count \(arrayForDisplay.count)")
        HAPlatformSelectionController.disableSendBtn(sendBtn: sendBtn, displayCount: arrayForDisplay.count, text: textView.text)

        
        if arrayForDisplay.count > 3 {
            let offsetX = CGFloat(Double(arrayForDisplay.count - 1) * 100.0) + 10.0 * CGFloat(arrayForDisplay.count - 1)
            
            
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.scrollView.contentOffset = CGPoint(x: offsetX, y: 0.0)
                self?.view.layoutIfNeeded()
//                self?.contentView.isUserInteractionEnabled = true
            }
        }
        
        
//        print("reloadScrollViewImages: \(wordCountLabelMove)")
    }
    
    //MARK: UIButton Linked Actions
    
    @IBAction func clickGalleryArrow(_ sender: UIButton) {
        if sender.isSelected == true {//show
            self.placeWordCountLimit()
            UIView.animate(withDuration: 0.5, animations: {
                print("show")
                
                self.galleryArrowBtn.transform = CGAffineTransform(rotationAngle: 0.0)
//                self.contentView.superview?.transform = (self.contentView.superview?.transform.translatedBy(x: -(self.contentView.superview?.transform.tx)!, y: (self.contentView.superview?.transform.ty)!))!
                self.contentView.superview?.frame.origin.x = 0
                self.scrollView.superview?.layoutIfNeeded()
            }, completion: nil)
            sender.isSelected = false
        } else {//hide
            self.placeWordCountLimit()
            UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                print("hide")
                self.galleryArrowBtn.transform = self.scrollView.transform.rotated(by: CGFloat(M_PI-0.000001))
                
//                self.contentView.superview?.transform = (self.contentView.superview?.transform.translatedBy(x: (self.contentView.superview?.transform.tx)! + UIScreen.main.bounds.width, y: (self.contentView.superview?.transform.ty)!))!
                self.contentView.superview?.frame.origin.x = UIScreen.main.bounds.size.width
                self.scrollView.superview?.layoutIfNeeded()
            }, completion: nil)
            sender.isSelected = true
        }

    }

    
    internal func customisedTZImagePickerControllerConfig(TZ : TZImagePickerController){
        if TZ.maxImagesCount == 9 {//ImageVc
            TZ.allowPickingOriginalPhoto = false
            TZ.allowPickingVideo = false
            TZ.selectedAssets = selected_assets
        } else if TZ.maxImagesCount == 1 {//VideoVc
            TZ.allowPickingImage = false
        }
        
        TZ.allowPickingGif = false
        TZ.allowTakePicture = false
        TZ.barItemTextColor = UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        TZ.navigationBar.barTintColor = UIColor(colorLiteralRed: 250.0/255.0, green: 235.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        TZ.navigationBar.isTranslucent = false
        TZ.navigationBar.tintColor = UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        TZ.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(colorLiteralRed: 58.0/255.0, green: 89.0/255.0, blue: 153.0/255.0, alpha: 1.0)]
        present(TZ, animated: true, completion: nil)
    }
    
    @IBAction func clickpic(_ sender: Any) {
        let picVC = TZImagePickerController(maxImagesCount: 9, delegate: self)!
        customisedTZImagePickerControllerConfig(TZ: picVC)
        
    }
    
    @IBAction func clickvideo(_ sender: Any) {
        
        let videoVC = TZImagePickerController(maxImagesCount: 1, delegate: self)!
        customisedTZImagePickerControllerConfig(TZ: videoVC)
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
        popVC.textForSend = textView.text
        popVC.LoginVC = UIApplication.shared.keyWindow?.rootViewController as! HALoginVC!
        present(popVC, animated: true, completion: nil)
    }
    

    @IBAction func dismissBtn(_ sender: Any) {
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func sendBtn(_ sender: UIButton) {
        textView.resignFirstResponder()
        
        if postVCMgr.getCurrentNetworkStatus() == "WIFI" {
            print("connected to WIFI :)")
            postVCMgr.sendDataFilter(text: textView.text, images: imageInGalleryArray, video: videoInGalleryArray, presentFrom: self)
            
        } else if postVCMgr.getCurrentNetworkStatus() == "no network"{
            print("Not connected to WIFI yet")
            let actionSheetController = UIAlertController(title: "No Internet Connection", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (cancelAction) in
            })
            actionSheetController.addAction(cancelAction)
            
            self.present(actionSheetController, animated: true, completion: nil)
            
        } else {
            let actionSheetController = UIAlertController(title: "Not connected to WIFI yet, do you want to continue ?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (doneAction) in
               self.postVCMgr.sendDataFilter(text: self.textView.text, images: self.imageInGalleryArray, video: (self.videoInGalleryArray), presentFrom: self)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (cancelAction) in
            })
            actionSheetController.addAction(cancelAction)
            actionSheetController.addAction(continueAction)

            self.present(actionSheetController, animated: true, completion: nil)
        }

    }
    
    @IBAction func clickSidePanel(_ sender: UIButton) {
        textView.resignFirstResponder()
        let sidePanelSB = UIStoryboard(name: "HASidePanel", bundle: nil)
        let sidePanelVC = sidePanelSB.instantiateInitialViewController() as! HASidePanel
        self.sidePanelVC = sidePanelVC
        let sidePandelTableView = sidePanelVC.tableView
        sidePandelTableView?.frame = CGRect(x: 0, y: 0, width: 0, height: view.bounds.height)
        sidePandelTableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 50))
        let coverView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        coverView.backgroundColor = UIColor.black
        coverView.alpha = 0.0

        UIView.animate(withDuration: 0.3) {
            coverView.alpha = 0.6
            self.view.addSubview(coverView)
            sidePandelTableView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: self.view.bounds.height)
            self.view.addSubview(sidePandelTableView!)

        }

        
    }
    
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("HAPostController deinit")
    }

    
}

extension HAPostController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        print("didFinishPickingPhotos: \(wordCountLabelMove)")

        if photos.count > 0 && videoInGalleryArray.count == 0{
            scrollView.isHidden = false
//            galleryArrowBtn.isHidden = false
            HA_fitScreen()
            if  wordCountLabelMove == true{
                placeWordCountLimit()
            }
            sendBtn.isEnabled = true
        }

        if imageInGalleryArray.count == 0 {
            wordCountLabelMove = !wordCountLabelMove
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

            
            
            reloadScrollViewImages()

        }
        
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: Any!) {
        TZImageManager.default().getVideoWithAsset(asset) { [weak self] (AVPlayerItem, info) in
            DispatchQueue.main.async {
                if self?.imageInGalleryArray.count == 0 {
                    self?.scrollView.isHidden = false
//                    self?.galleryArrowBtn.isHidden = false
                    self?.HA_fitScreen()

                    if  self?.wordCountLabelMove == true{
                        self?.placeWordCountLimit()
                    }
                    self?.sendBtn.isEnabled = true
                }
                
                if self?.videoInGalleryArray.count == 0 {
                    self?.wordCountLabelMove = !(self?.wordCountLabelMove)!
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
//        let newInputCount = abs(textView.text.unicodeScalars.count - currentInputUnicodeScalarsCount)
        textView.becomeFirstResponder()
        let currentRange = textView.selectedRange
        
        if textView.text.unicodeScalars.count > 0{
            TwitterWordCount = textView.text.unicodeScalars.count
//            sendBtn.isEnabled = true
            placeHolderLabel.isHidden = true
        } else if arrayForDisplay.count == 0 && textView.text.unicodeScalars.count == 0{
            TwitterWordCount = 0
//            sendBtn.isEnabled = false
            placeHolderLabel.isHidden = false
        } else if textView.text.unicodeScalars.count == 0 {
            TwitterWordCount = 0
        }
        else {
            TwitterWordCount = textView.text.unicodeScalars.count
        }
        
        wordCountLabel.text = "\(140 - TwitterWordCount) Twitter, \(63206 - TwitterWordCount) Facebook"

        if 140 - TwitterWordCount < 0 {

            let count = 140 - TwitterWordCount
            let endex = "\(count)".characters.count
            
            wordCountLabel.attributedText = postVCMgr.HA_attributedText(text: wordCountLabel.text!, textColor: UIColor.red, rangeForTextColor: NSMakeRange(0, endex))

        }
    
        textView.selectedRange = currentRange
        HAPlatformSelectionController.disableSendBtn(sendBtn: sendBtn, displayCount: arrayForDisplay.count, text: textView.text)
    }

    
}

