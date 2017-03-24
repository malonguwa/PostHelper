//
//  HAPostHelperAdvantureModel.swift
//  PostHelper
//
//  Created by LONG MA on 24/3/17.
//  Copyright © 2017 HnA. All rights reserved.
//

import Foundation
class HAPostHelperAdvantureModel : NSObject {
    var weFirstMetOn : String = "??/??/????"
    var FbPostImageCount : Int = 0
    var FbPostVideoCount : Int = 0
    var TwPostImageCount : Int = 0
    var TwPostVideoCount : Int = 0
    var totalPostOnAllPlatforms : Int = 0
    /*
    init(FbImageCount: Int, FbVideoCount: Int, TwImageCount: Int, TwVideoCount: Int) {
        FbPostImageCount = FbImageCount
        FbPostVideoCount = FbVideoCount
        TwPostImageCount = TwImageCount
        TwPostVideoCount = TwVideoCount
    }
    */
    
    init(dictFromplist : NSMutableDictionary) {
        for (key,value) in dictFromplist {
            switch key as! String{
            case "weFirstMetOn":
                weFirstMetOn = value as! String
                break
            case "FbPostImageCount":
                FbPostImageCount = value as! Int
                break
            case "FbPostVideoCount":
                FbPostVideoCount = value as! Int
                break
            case "TwPostImageCount":
                TwPostImageCount = value as! Int
                break
            case "TwPostVideoCount":
                TwPostVideoCount = value as! Int
                break
            case "totalPostOnAllPlatforms":
                totalPostOnAllPlatforms = value as! Int
                break

            default:
                break
            }
        }
    }
    
//    dict!.setValue(dict!["firstTime"], forKey: "firstTime")
//    dict!.setValue(dict!["weFirstMetOn"], forKey: "weFirstMetOn")
//    dict!.setValue((dict!["FbPostImageCount"] as! Int) + FbPostImageCount, forKey: "FbPostImageCount")
//    dict!.setValue((dict!["FbPostVideoCount"] as! Int) + FbPostVideoCount, forKey: "FbPostVideoCount")
//    dict!.setValue((dict!["TwPostImageCount"] as! Int) + TwPostImageCount, forKey: "TwPostImageCount")
//    dict!.setValue((dict!["TwPostVideoCount"] as! Int) + TwPostVideoCount, forKey: "TwPostVideoCount")

}
