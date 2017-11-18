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
    
    
    class func read() {
        if ( Auth.auth().currentUser == nil ) {
            return
        }
        
        AppData.sharedInstance.treesArr = Array<Tree>()
        
        AppData.sharedInstance.treeNode
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;
                
                if ( value == nil) {
                    return
                }
                
                
                
                for any in (value?.allValues)!
                {
                    let tree : [String : String] = any as! Dictionary <String, String>;
                    
                    let treeName : String = tree["nameKey"]!;
                    let treeDescription : String = tree["descriptionKey"]!;
                    let treeSpecies : String = tree["speciesKey"]!;
                    let treeRating : String = tree["ratingKey"]!;
                    let treeHowToFind : String = tree["howToFindKey"]!;
                    let treeLatitude : String = tree["latitudeKey"]!;
                    let treeLongitude : String = tree["longitudeKey"]!;
                    let treePopularity : String = tree["popularityKey"]!;
                    
                    let treeLat = Double(treeLatitude)
                    let treeLong = Double(treeLongitude)
                    let treePhoto : NSData = NSData() //this 💩 is fake
                    
                    let readEntry = Tree(name: treeName,
                                         description: treeDescription,
                                         treeLat: treeLat!,
                                         treeLong: treeLong!,
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

