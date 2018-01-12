import Foundation
import UIKit
import Firebase

class UserTreesManager: NSObject {
    
    class func deleteUserTree(tree: Tree, completion: @escaping (Bool) -> Void) {
        AppData.sharedInstance.treeNode
            .child(tree.treeID)
            .removeValue()
        
        AppData.sharedInstance.userTreesNode
            .child(Auth.auth().currentUser!.uid)
            .child(tree.treeID)
            .removeValue()
        
        AppData.sharedInstance.favouritesNode
            .child(Auth.auth().currentUser!.uid)
            .child(tree.treeID)
            .removeValue()
        
        completion(true)
    }
    
    
    class func loadUserTrees(completion: @escaping ([Tree]?) -> Void) {
        AppData.sharedInstance.userTreesArr = []
        
        if ( Auth.auth().currentUser == nil ) {
            completion(nil)
            return
        }
        
        AppData.sharedInstance.userTreesNode
            .child(Auth.auth().currentUser!.uid)
//            .observe(.value, with: { (userTreesSnapshot) in
            .observeSingleEvent(of: .value) { (userTreesSnapshot) in

        
                let allUserTrees = userTreesSnapshot.value as? [String: Any]
                
                if (allUserTrees == nil) {
                    completion(nil)
                    return
                }
                
                
                for userTree in (allUserTrees?.keys)!
                {
                    
                    AppData.sharedInstance
                        .treeNode
                        .child(userTree)
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
                            
                            let userTree = Tree(name: treeName,
                                                description: treeDescription,
                                                treeLat: treeLatitude,
                                                treeLong: treeLongitude,
                                                photo: nil)
                            
                            let treeRat = Double(treeRating)
                            let treePop = Int(treePopularity)
                            userTree.treeSpecies = treeSpecies
                            userTree.treeRating = treeRat
                            userTree.treeHowToFind = treeHowToFind
                            userTree.treePopularity = treePop
                            userTree.treePhotoURL = treePhotoURL!
                            userTree.treeID = treeID
                            userTree.treeCreator = treeCreator
                            userTree.treeCreatorName = treeCreatorName
                            
                            AppData.sharedInstance.userTreesArr.append(userTree)
                            print (" After Append\(AppData.sharedInstance.userTreesArr.count)")
                            
                        })
                }
                
                print("\(#function) - \(AppData.sharedInstance.userTreesArr.count)")
                completion(AppData.sharedInstance.userTreesArr)
            }
        
    }
    
}
