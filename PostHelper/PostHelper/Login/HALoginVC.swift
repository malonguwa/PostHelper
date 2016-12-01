//
//  ViewController.swift
//  PostHelper
//
//  Created by LONG MA on 15/11/16.
//  Copyright © 2016 HnA. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import SafariServices

class HALoginVC: UIViewController, SFSafariViewControllerDelegate {

    // MARK: Property
    /// Btn : Add facebook account
    @IBOutlet weak var addFBAccountBtn: UIButton!
    
    // MARK: Function
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Btn Event
    /// addFBAccountBtn event
    @IBAction func addFBAccountClick(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.loginBehavior = .native
        loginManager.logIn([.publicProfile, ReadPermission.custom("user_photos")], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                
                print("Logged in with read permission!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
                loginManager.logIn([.publishActions], viewController: self) { loginResult in
                    switch loginResult {
                    case .failed(let error):
                        print(error)
                    case .cancelled:
                        print("User cancelled login.")
                    case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                        
                        print("Logged in with read permission!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
                    }
                    
                }
            }
        }
        
//        .custom("user_photos")
//        loginManager.logIn([.publishActions], viewController: self) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                
//                print("Logged in with read permission!, \n grantedPermissions: \(grantedPermissions), \n declinedPermissions: \(declinedPermissions),\n accessToken: \(accessToken)")
//            }
//            
//        }
        

        
        
        

    }
    
    @IBAction func FBLogOutClick(_ sender: Any) {
        guard let token = AccessToken.current else {
            print("token is nil")
            return
        }
        
//        let safariVC = SFSafariViewController.init(url: URL(string: "https://www.facebook.com/logout.php?next=https://example.com&access_token=\(token.authenticationToken)")!)
//        // https://www.facebook.com/logout.php?next=http://example.com&access_token=xxx
//
//        safariVC.delegate = self
//        present(safariVC, animated: true, completion: {
//            
//        })
        
        

        GraphRequest(graphPath: "/me/permissions", parameters:[:], accessToken: token, httpMethod: GraphRequestHTTPMethod.DELETE, apiVersion: GraphAPIVersion.defaultVersion).start { (response, requestResult) in
            print("\(response)\n\(requestResult)")
        }
        
        let loginManager = LoginManager()
        loginManager.logOut()

    }
}
