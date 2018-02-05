import UIKit
import Firebase
import CoreLocation
import MapKit


class SaveTree: NSObject {
    
    var tempUrl: URL!

    class func saveTree(tree: Tree, coverPhoto: Photo, completion: @escaping (Bool) -> Void) {
        print("Saving...")
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
        
//        let storage = Storage.storage()
//        
//        let photoID: String = tree.treeName + "|" + String(describing: Date())
        
//        let storageRef = storage.reference()
//        let imagesRef = storageRef.child(photoID)
//
//        let photoData = tree.treePhotoData! as Data
        
        if tree.treeDescription == "Enter description..." {
            tree.treeDescription = ""
        }
            
            let creator = Auth.auth().currentUser?.uid
            let creatorName = Auth.auth().currentUser?.displayName
        
                let treeDict: [String : Any] = [
                    "idKey": tree.treeID,
                    "nameKey": tree.treeName,
                    "descriptionKey": tree.treeDescription!,
                    "speciesKey": tree.treeSpecies!,
                    "ratingKey": tree.treeRating!,
                    "howToFindKey": tree.treeHowToFind!,
                    "latitudeKey": tree.treeLatitude,
                    "longitudeKey": tree.treeLongitude,
                    "popularityKey":tree.treePopularity,
                    "photoKey":coverPhoto.photoURL,
                    "creatorKey":creator!,
                    "creatorNameKey":creatorName!,
                ]
                
                AppData.sharedInstance.treeNode
                    .child(tree.treeID)
                    .setValue(treeDict)
                
                AppData.sharedInstance.userTreesNode
                    .child(Auth.auth().currentUser!.uid)
                    .child(tree.treeID)
                    .setValue(["treeIDKey": tree.treeID])
        
            completion(true)
        }
    
    class func updateTree(tree: Tree, completion: @escaping (Bool) -> Void) {
        
        let url = tree.treePhotoURL.absoluteString

            let treeDict: [String : Any] = [
                "idKey": tree.treeID,
                "nameKey": tree.treeName,
                "descriptionKey": tree.treeDescription!,
                "speciesKey": tree.treeSpecies!,
                "ratingKey": tree.treeRating!,
                "howToFindKey": tree.treeHowToFind!,
                "latitudeKey": tree.treeLatitude,
                "longitudeKey": tree.treeLongitude,
                "popularityKey": tree.treePopularity,
                "photoKey": url,
                "creatorKey": tree.treeCreator,
                "creatorNameKey": tree.treeCreatorName,
            ]
            
            AppData.sharedInstance.treeNode
                .child(tree.treeID)
                .setValue(treeDict)
        
        completion(true)
        
        }
}
