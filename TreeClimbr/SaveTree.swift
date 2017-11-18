import UIKit
import Firebase

class SaveTree: NSObject {

    class func saveTree(tree: Tree) {
        
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
      
        var treeDict: [String : Any] = ["nameKey": tree.treeName,
                                        "descriptionKey": tree.treeDescription,
                                        "speciesKey": tree.treeSpecies,
                                        "ratingKey": tree.treeRating,
                                        "howToFindKey": tree.treeHowToFind,
                                        "latitudeKey": tree.treeLatitude,
                                        "longitudeKey": tree.treeLongitude,
                                        "popularityKey":tree.treePopularity,
                                        "photoKey": tree.treePhotoData
        ]
        
        
//        AppData.sharedInstance.dataNode
//            .child(AppData.sharedInstance.curUser!.uid)
//            .child(inpEntry.uid)
//            .setValue(entryDict)
    }
    
}


