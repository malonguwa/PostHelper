//
//  HAPostHelperAdvantureVC.swift
//  PostHelper
//
//  Created by LONG MA on 24/3/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import UIKit

class HAPostHelperAdvantureVC : UIViewController {
    @IBOutlet weak var firstMetLabel: UILabel!
    @IBOutlet weak var TWImageCountLabel: UILabel!
    @IBOutlet weak var TWVideoCountLabel: UILabel!
    @IBOutlet weak var FBImageCountLabel: UILabel!
    @IBOutlet weak var FBVideoCountLabel: UILabel!
    @IBOutlet weak var totalPostCount: UILabel!
    var dictFromPlistModel: HAPostHelperAdvantureModel! {
        willSet {
            firstMetLabel.text = "\(newValue.weFirstMetOn)"
            TWImageCountLabel.text = "\(newValue.TwPostImageCount)"
            TWVideoCountLabel.text = "\(newValue.TwPostVideoCount)"
            FBImageCountLabel.text = "\(newValue.FbPostImageCount)"
            FBVideoCountLabel.text = "\(newValue.FbPostVideoCount)"
            totalPostCount.text = "\(newValue.totalPostOnAllPlatforms)"
        }
    }
    
    override func viewDidLoad() {
        
        //从plist中读取字典，并给相关label赋值
        let dict = (UIApplication.shared.delegate as! AppDelegate).readPostHelperAdvanturePlistInfo()
        dictFromPlistModel = HAPostHelperAdvantureModel.init(dictFromplist: dict!)
        
    }
    
    @IBAction func dismissPHA_VC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func clearHistory(_ sender: UIButton) {
        let dict = (UIApplication.shared.delegate as! AppDelegate).deletePostHelperAdvanturePlistInfo()
        dictFromPlistModel = HAPostHelperAdvantureModel.init(dictFromplist: dict)
//        print("从plist中读出的数据: \(dict)")
        
//        firstMetLabel.text = "666"
//        TWImageCountLabel.text = "666"
//        TWVideoCountLabel.text = "666"
//        FBImageCountLabel.text = "666"
//        FBVideoCountLabel.text = "666"
//        totalPostCount.text = "666"
        
        
        
    }
    
    deinit {
        print("HAPostHelperAdvantureVC deinit")
    }
}
