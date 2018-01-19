import Foundation
import Firebase

class ReadTrees: NSObject {
    
    
    class func read(completion: @escaping ([Tree]?) -> Void) {
//        if ( Auth.auth().currentUser == nil ) {
//            completion(nil)
//            return
//        }
        
        
        
        
        AppData.sharedInstance
            .treeNode
            .observe (.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    completion(nil)
                    return
                }
                
                AppData.sharedInstance.treesArr = Array<Tree>()
                
                
                for any in (value?.allValues)!
                {
                    let tree : [String : Any] = any as! Dictionary <String, Any>
                    
                    let treeID = tree["idKey"] as! String
                    let treeDescription = tree["descriptionKey"] as! String
                    let treeHowToFind = tree["howToFindKey"] as! String
                    let treeLatitude = tree["latitudeKey"] as! Double
                    let treeLongitude = tree["longitudeKey"]  as! Double
                    let treeName : String = tree["nameKey"] as! String
                    let treePopularity = tree["popularityKey"] as! Int
                    let treeRating = tree["ratingKey"] as! Double
                    let treeSpecies : String = tree["speciesKey"] as! String
                    let treePhotoStr = tree["photoKey"] as! String
                    let treeCreator = tree["creatorKey"] as! String
                    let treeCreatorName = tree["creatorNameKey"] as! String
//                    let treeComments = tree["commentsKey"] as! Array
                    
                    let treePhotoURL = URL(string: treePhotoStr)
                    
                    let readTree = Tree(name: treeName,
                                        description: treeDescription,
                                        treeLat: treeLatitude,
                                        treeLong: treeLongitude,
                                        photo: nil)
                    
                    
                    let treeRat = Double(treeRating)
                    let treePop = Int(treePopularity)
                    readTree.treeSpecies = treeSpecies
                    readTree.treeRating = treeRat
                    readTree.treeHowToFind = treeHowToFind
                    readTree.treePopularity = treePop
                    readTree.treePhotoURL = treePhotoURL!
                    readTree.treeID = treeID
                    readTree.treeCreator = treeCreator
                    readTree.treeCreatorName = treeCreatorName
                    
                    AppData.sharedInstance.treesArr.append(readTree)
                    
                }
                
                print("\(#function) - \(AppData.sharedInstance.treesArr.count)")
                completion(AppData.sharedInstance.treesArr)
            })
    }
    
}
