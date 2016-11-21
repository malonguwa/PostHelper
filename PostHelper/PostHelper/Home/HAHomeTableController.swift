//
//  HAHomeTableController.swift
//  PostHelper
//
//  Created by LONG MA on 21/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookLogin

class HAHomeTableController: UITableViewController {

    private var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {

            let loginManager = LoginManager()
            loginManager.logIn([.publishActions], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):

                    print("Logged in with publish permisson!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
                    
                    self.flag = 1
//                    guard let navi = self.navigationController else{
//                        return
//                    }
                    
                    
                    self.performSegue(withIdentifier: "homeToPost", sender: nil)
 
                }
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return flag == 1 ? true : false
    }

}
