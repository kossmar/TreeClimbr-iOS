

import UIKit
import Firebase

class FavouritesManager: NSObject {
    
    class func saveFavourite(tree: Tree, completion: @escaping (Bool) -> Void) {
        
        
        if ( Auth.auth().currentUser == nil )
        {
            completion(false)
            return
        }
        
        let faveDict: [String: Any] = [
            "treeIDKey": tree.treeID
        ]
        
        AppData.sharedInstance.favouritesNode
            .child(Auth.auth().currentUser!.uid)
            .child(tree.treeID)
            .setValue(faveDict)
        
        completion(true)
    }
    
    class func loadFavourites(completion: @escaping ([Tree]?) -> Void) {
        AppData.sharedInstance.favouritesArr = []
        
        if ( Auth.auth().currentUser == nil ) {
            completion(nil)
            return
        }
        
        AppData.sharedInstance.favouritesNode
            .child(Auth.auth().currentUser!.uid)
//            .observe(.value, with: { (favesSnapshot) in
            .observeSingleEvent(of: .value, with: { (favesSnapshot) in
                
        
                let allFaveTrees = favesSnapshot.value as? [String: Any]
                
                if (allFaveTrees == nil) {
                    completion(nil)
                    return
                }
                
                
//                AppData.sharedInstance.favouritesArr = []
                for favTree in (allFaveTrees?.keys)!
                {
                    
                    AppData.sharedInstance
                        .treeNode
                        .child(favTree)
                        .observeSingleEvent (of: .value, with: { (treeSnapshot) in
                            
                            let treeDict = treeSnapshot.value as? [String: Any]
                            
                            if treeDict == nil
                            {
                                completion(nil)
                                return
                            }
                            
                            
                            let treeID = treeDict?["idKey"] as! String
                            let treeDescription = treeDict?["descriptionKey"] as! String
                            let treeHowToFind = treeDict?["howToFindKey"] as! String
                            let treeLatitude = treeDict?["latitudeKey"] as! Double
                            let treeLongitude = treeDict?["longitudeKey"]  as! Double
                            let treeName : String = treeDict?["nameKey"] as! String
                            let treePopularity = treeDict?["popularityKey"] as! Int
                            let treeRating = treeDict?["ratingKey"] as! Double
                            let treeSpecies : String = treeDict?["speciesKey"] as! String
                            let treePhotoStr = treeDict?["photoKey"] as! String
                            let treeCreator = treeDict?["creatorKey"] as! String
                            let treeCreatorName = treeDict?["creatorNameKey"] as! String
                            let treePhotoURL = URL(string: treePhotoStr)
                            
                            let faveTree = Tree(name: treeName,
                                                description: treeDescription,
                                                treeLat: treeLatitude,
                                                treeLong: treeLongitude,
                                                photo: nil)
                            
                            let treeRat = Double(treeRating)
                            let treePop = Int(treePopularity)
                            faveTree.treeSpecies = treeSpecies
                            faveTree.treeRating = treeRat
                            faveTree.treeHowToFind = treeHowToFind
                            faveTree.treePopularity = treePop
                            faveTree.treePhotoURL = treePhotoURL!
                            faveTree.treeID = treeID
                            faveTree.treeCreator = treeCreator
                            faveTree.treeCreatorName = treeCreatorName
                            
                            AppData.sharedInstance.favouritesArr.append(faveTree)
                            print (" After Append\(AppData.sharedInstance.favouritesArr.count)")
                            
                        })
                }
                
                print("\(#function) - \(AppData.sharedInstance.favouritesArr.count)")
                completion(AppData.sharedInstance.favouritesArr)
            })
        
    }
    
    class func removeFavourite(tree: Tree) {
        
        AppData.sharedInstance.favouritesNode
        .child(Auth.auth().currentUser!.uid)
        .child("\(tree.treeID)")
        .removeValue()
        
    }
    
    
}

