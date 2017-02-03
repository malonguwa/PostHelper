//
//  HAUploadStatusController.swift
//  PostHelper
//
//  Created by LONG MA on 3/2/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HAUploadStatusController: UITableViewController {
    @IBOutlet weak var TWPhotoUploadView: UIView!
    @IBOutlet weak var TWVideoUploadView: UIView!
    @IBOutlet weak var FBPhotoUploadView: UIView!
    @IBOutlet weak var FBVideoUploadView: UIView!
    
    
    override func viewDidLoad() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: UIScreen.main.bounds.size.height * 0.5 - 180))
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if hasAuthToTwitter! && hasAuthToFacebook! {
            TWPhotoUploadView = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: TWPhotoUploadView.frame.size.width, height:TWPhotoUploadView.frame.size.height))
            TWVideoUploadView = M13ProgressViewRing(frame: CGRect(x: 0, y: 0, width: TWPhotoUploadView.frame.size.width, height:TWPhotoUploadView.frame.size.height))

        }
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        
    }
    
}
