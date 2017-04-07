//
//  ShareViewController.swift
//  PostHelperShare
//
//  Created by LONG MA on 2/4/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    
    override func viewDidLoad() {
//        setUpView()
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        label.text = "aaaaaa"
//        label.backgroundColor = UIColor.blue
//        view.addSubview(label)

    }
    
    func setUpView() {
        let viewFrame = CGRect(x: 0, y: 0, width: 150, height: 300)
        self.view = UIView(frame: viewFrame)
        self.view.backgroundColor = UIColor.clear
        
        let width: CGFloat = UIScreen.main.bounds.size.width
        let height: CGFloat = UIScreen.main.bounds.size.height
        let newView = UIView(frame: CGRect(x: (width * 0.10), y: (height * 0.25), width: (width * 0.75), height: (height / 2)))
        newView.backgroundColor = UIColor.yellow
        self.view.addSubview(newView)
    }
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        return true
    }

    override func didSelectPost() {
        
        print(extensionContext!.inputItems.count)
        
        
//        let activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
//        activityIndicatorView.backgroundColor = UIColor.red
//        let x = (view.frame.size.width - activityIndicatorView.frame.size.width) * 0.5
//        let y = (view.frame.size.height - activityIndicatorView.frame.size.height) * 0.5
//        let width = activityIndicatorView.frame.size.width
//        let height = activityIndicatorView.frame.size.height
//        activityIndicatorView.frame = CGRect(x: x, y: y, width: width, height: height)
//        activityIndicatorView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
//        view.addSubview(activityIndicatorView)
//        
//        activityIndicatorView.startAnimating()
        
//        var urlExisted = false
        
        
        
        let inputItem = extensionContext?.inputItems.first as! NSExtensionItem
    
        let itemProvider = inputItem.attachments?.first as! NSItemProvider
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") == true {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (item, error) in
                
                if item is NSURL || item is URL {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

//                    activityIndicatorView.stopAnimating()
                }
            })
//            urlExisted = true
        }

//        if urlExisted == true {
//            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//        }
        
        
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
