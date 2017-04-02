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

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        return true
    }

    override func didSelectPost() {
        
        print(extensionContext!.inputItems.count)
        
//            print(inputItem.element)
        let inputItem = extensionContext?.inputItems.first as! NSExtensionItem
    
        let itemProvider = inputItem.attachments?.first as! NSItemProvider
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") == true {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (item, error) in
                
                if item is NSURL || item is URL {
                    print(item)
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            })
        }
        
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
