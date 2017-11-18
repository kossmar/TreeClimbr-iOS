import UIKit
import Firebase

class SaveTree: NSObject {

    class func saveTree(tree: Tree) {
        print("Saving...")
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
        
  //      let treeID: String = AppData.sharedInstance.curUser!.uid + "|" + tree.treeName
        
        
        let treeDict: [String : Any] = [
//            "idKey": treeID,
            "nameKey": tree.treeName,
            "descriptionKey": tree.treeDescription!,
            "speciesKey": tree.treeSpecies!,
            "ratingKey": tree.treeRating!,
            "howToFindKey": tree.treeHowToFind!,
            "latitudeKey": tree.treeLatitude,
            "longitudeKey": tree.treeLongitude,
            "popularityKey":tree.treePopularity!,
//            "photoKey": tree.treePhotoData
        ]

        AppData.sharedInstance.treeNode
            .child(AppData.sharedInstance.curUser!.uid)
            .child(tree.treeName)
            .setValue(treeDict)
    }
    
}


