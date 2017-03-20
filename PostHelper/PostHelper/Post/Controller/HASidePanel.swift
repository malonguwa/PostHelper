//
//  HASidePanel.swift
//  PostHelper
//
//  Created by LONG MA on 20/3/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation

class HASidePanel : UITableViewController {
//    weak var coverView : UIView?
//    weak var sidePandelTableView: UITableView?
    
    
    class func sidePandelTableViewSetUp(sidePandelTableView: UITableView) {
        
        sidePandelTableView.frame = CGRect(x: 0, y: 0, width: 0, height: (UIApplication.shared.keyWindow?.bounds.height)!)
        sidePandelTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width:(UIApplication.shared.keyWindow?.bounds.width)! * 0.7, height: 50))
        
    }
    
    class func sidePandelCoverViewSetUp() -> UIView {
        let coverView = UIView(frame: CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.bounds.width)!, height: (UIApplication.shared.keyWindow?.bounds.height)!))
        coverView.backgroundColor = UIColor.black
        coverView.alpha = 0.0
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(HAPostController.tapToDismissSidePanel))
        coverView.addGestureRecognizer(tapGes)

        return coverView
    }
    
    
//    class func sidePanelSetUp (view: UIView!) -> HASidePanel{
//        let sidePanelSB = UIStoryboard(name: "HASidePanel", bundle: nil)
//        let sidePanelVC = sidePanelSB.instantiateInitialViewController() as! HASidePanel
////        self.sidePanelVC = sidePanelVC
//        let sidePandelTableView = sidePanelVC.tableView
//        self.sidePandelTableView = sidePandelTableView
//        
//        
//        sidePandelTableView?.frame = CGRect(x: 0, y: 0, width: 0, height: view.bounds.height)
//        
//        sidePandelTableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width:(UIApplication.shared.keyWindow?.bounds.width)! * 0.7, height: 50))
//        let coverView = UIView(frame: CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.bounds.width)!, height: (UIApplication.shared.keyWindow?.bounds.height)!))
//        coverView.backgroundColor = UIColor.black
//        coverView.alpha = 0.0
//        let tapGes = UITapGestureRecognizer(target: self, action: #selector(HASidePanel.tapToDismissSidePanel))
//        coverView.addGestureRecognizer(tapGes)
//        UIView.animate(withDuration: 0.3) {
//            coverView.alpha = 0.6
//            view.addSubview(coverView)
//            sidePandelTableView?.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.bounds.width)! * 0.7, height: (UIApplication.shared.keyWindow?.bounds.height)!)
//            view.addSubview(sidePandelTableView!)
//        }
//
//        
//        return sidePanelVC
//        
//    }
    
}
