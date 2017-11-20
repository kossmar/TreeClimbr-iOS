//
//  ReadTrees.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2017-11-18.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import Foundation
import Firebase

class ReadTrees: NSObject {
    
    
    class func read(completion: () -> Void) {
        if ( Auth.auth().currentUser == nil ) {
            return
        }
        
        AppData.sharedInstance.treesArr = Array<Tree>()
        
        let userID = Auth.auth().currentUser?.uid
        
        AppData.sharedInstance.treeNode
            .observeSingleEvent (of: .value, with: { (snapshot) in
              
                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    return
                }
                
                
                for any in (value?.allValues)!
                {
                    let tree : [String : Any] = any as! Dictionary <String, Any>
                    
                    let treeDescription = tree["descriptionKey"] as! String
                    let treeHowToFind = tree["howToFindKey"] as! String
                    let treeLatitude = tree["latitudeKey"] as! Double
                    let treeLongitude = tree["longitudeKey"]  as! Double
                    let treeName : String = tree["nameKey"] as! String
                    let treePopularity = tree["popularityKey"] as! Int
                    let treeRating = tree["ratingKey"] as! Double
                    let treeSpecies : String = tree["speciesKey"] as! String
                    
//                    let treeLat = Double(treeLatitude)
//                    let treeLong = Double(treeLongitude)
                    let treePhoto : NSData = NSData() //this 💩 is fake
                    
                    let readEntry = Tree(name: treeName,
                                         description: treeDescription,
                                         treeLat: treeLatitude,
                                         treeLong: treeLongitude,
                                         photo: treePhoto)
                    
                    //💩💩💩💩💩💩💩💩💩💩💩💩
                    let treeRat = Double(treeRating)
                    let treePop = Int(treePopularity)
                    readEntry.treeSpecies = treeSpecies
                    readEntry.treeRating = treeRat
                    readEntry.treeHowToFind = treeHowToFind
                    readEntry.treePopularity = treePop
                    //💩💩💩💩💩💩💩💩💩💩💩💩
                    
                    AppData.sharedInstance.treesArr.append(readEntry)
                    
                    print (AppData.sharedInstance.treesArr)
                    
                    
                }
                
            })
     completion()
    }

}

//"nameKey": tree.treeName,
//"descriptionKey": tree.treeDescription!,
//"speciesKey": tree.treeSpecies!,
//"ratingKey": tree.treeRating!,
//"howToFindKey": tree.treeHowToFind!,
//"latitudeKey": tree.treeLatitude,
//"longitudeKey": tree.treeLongitude,
//"popularityKey":tree.treePopularity!,

