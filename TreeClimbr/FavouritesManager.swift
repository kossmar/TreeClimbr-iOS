//
//  FavouritesManager.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2017-11-23.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import UIKit
import Firebase

class FavouritesManager: NSObject {
    
    class func saveFavourite(user: User, tree: Tree, completion: @escaping (Bool) -> Void) {
        
        
        if ( Auth.auth().currentUser == nil )
        {
            completion(false)
            return
        }
        
        let faveDict: [String: Any] = [
            "treeIDKey": tree.treeID!
        ]
        
        AppData.sharedInstance.favouritesNode
            .child(user.uid)
            .child(tree.treeID!)
            .setValue(faveDict)
        
        completion(true)
    }
    
    class func loadFavourites(user: User, tree: Tree, completion: @escaping ([Tree]?) -> Void) {
        
        if ( Auth.auth().currentUser == nil ) {
            return
        }
        
        AppData.sharedInstance.favouritesNode.child(user.uid).observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if (value == nil) {
                completion(nil)
                return
            }
            
            AppData.sharedInstance.favouritesArr = Array<Tree>()
            
            for any in (value?.allValues)!
            {
                let treeDict : [String : Any] = any as! Dictionary <String, Any>
                
                let treeID = treeDict["treeIDKey"] as! String
                
                tree.treeID = treeID
                
                AppData.sharedInstance.favouritesArr.append(tree)
                
            }
            print("\(#function) - \(AppData.sharedInstance.favouritesArr.count)")
            completion(AppData.sharedInstance.favouritesArr)
        })
    }

}
