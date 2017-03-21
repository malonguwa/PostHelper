//
//  HASidePanel.swift
//  PostHelper
//
//  Created by LONG MA on 20/3/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
import SafariServices

class HASidePanel : UITableViewController, SFSafariViewControllerDelegate {
    var sidePanelRemoveAnimationNotify : Notification!
    
    override func viewDidLoad() {
        
        sidePanelRemoveAnimationNotify = Notification.init(name: Notification.Name(rawValue: "sidePanelRemoveAnimationNotification"), object: nil, userInfo: nil)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        switch indexPath.row {
        case 0:
            PHAcellClick()
            break
        case 1:
            CUcellClick()
            break
        case 2:
            PPcellClick()
            break
        default:
            break
        }
    }
    
    internal func PHAcellClick(){
        NotificationCenter.default.post(sidePanelRemoveAnimationNotify)
        

    }
    
    internal func CUcellClick(){
        
        NotificationCenter.default.post(self.sidePanelRemoveAnimationNotify)

        let actionSheetController = UIAlertController(title: "Contact Us", message: "please send email to \"malonguwa@gmail.com\" if you have any question about PostHelper", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (cancelAction) in
        })
        actionSheetController.addAction(cancelAction)
//        self.tableView.window?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
//        UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[0].present(actionSheetController, animated: true, completion: nil)

        self.present(actionSheetController, animated: true, completion: nil)

    }
    
    internal func PPcellClick(){
        NotificationCenter.default.post(sidePanelRemoveAnimationNotify)
        let safariVC = SFSafariViewController.init(url: URL(string: "https://www.iubenda.com/privacy-policy/8070421")!)
        
        safariVC.delegate = self
        present(safariVC, animated: true, completion: {
        })
    }
    

    
    internal func contactUsCellClick(){
        
    }
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
    
    deinit {
        print("HASidePandel deinit")
    }
    
}
