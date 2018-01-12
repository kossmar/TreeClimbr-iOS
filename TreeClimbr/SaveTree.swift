import UIKit
import Firebase
import CoreLocation
import MapKit


class SaveTree: NSObject {
    
    var tempUrl: URL!

    class func saveTree(tree: Tree, completion: @escaping (Bool) -> Void) {
        print("Saving...")
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        let photoID: String = tree.treeName + "|" + String(describing: Date())
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(photoID)
        
        let photoData = tree.treePhotoData! as Data
        
        if tree.treeDescription == "Enter description..." {
            tree.treeDescription = ""
        }
        
        imagesRef.putData(photoData, metadata: nil, completion: { (metadata, error) in
            
            if let error = error {
                print(error)
                completion(false)
                return
            }
            
//            let treeID: String = tree.treeName + "|" + String(describing: Date()) + "1"
//            tree.treeID = treeID
            
            let creator = Auth.auth().currentUser?.uid
            let creatorName = Auth.auth().currentUser?.displayName
            
            if let metadata = metadata, let downloadedURL = metadata.downloadURL() {
                print(downloadedURL)
                metadata.contentType = "image/jpeg"
                let url = downloadedURL.absoluteString
                
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
                    "photoKey":url,
                    "creatorKey":creator!,
                    "creatorNameKey":creatorName!,
//                    "commentKey": tree.treeComments
                ]
                
                AppData.sharedInstance.treeNode
                    .child(tree.treeID)
                    .setValue(treeDict)
                
                AppData.sharedInstance.userTreesNode
                    .child(Auth.auth().currentUser!.uid)
                    .child(tree.treeID)
                    .setValue(["treeIDKey": tree.treeID])
            }
            
            completion(true)
            
        })
    }
    
    class func updateTree(tree: Tree, completion: @escaping (Bool) -> Void) {
        
//        let popString = "\(tree.treePopularity)"
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
                //                    "commentKey": tree.treeComments
            ]
            
            AppData.sharedInstance.treeNode
                //            .child(AppData.sharedInstance.curUser!.uid)
                .child(tree.treeID)
                .setValue(treeDict)
        
        completion(true)
        
        }
}
