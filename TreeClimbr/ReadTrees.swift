import Foundation
import Firebase

class ReadTrees: NSObject {
    
    
    class func read(completion: () -> Void) {
        if ( Auth.auth().currentUser == nil ) {
            return
        }
        
        AppData.sharedInstance.treesArr = Array<Tree>()
        
//        let userID = Auth.auth().currentUser?.uid
        
        AppData.sharedInstance
            .treeNode
            .observe (.value, with: { (snapshot) in
              
                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    return
                }
                
                
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
                    
                    AppData.sharedInstance.treesArr.append(readTree)
                    
                    print (AppData.sharedInstance.treesArr)
                    
                }
                
            })
     completion()
    }

}
