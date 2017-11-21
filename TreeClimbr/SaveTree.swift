import UIKit
import Firebase


class SaveTree: NSObject {
    
    var tempUrl: URL!

    class func saveTree(tree: Tree) {
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
        
        let photoData = tree.treePhotoData as Data
        
        imagesRef.putData(photoData, metadata: nil, completion: { (metadata, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let metadata = metadata, let downloadedURL = metadata.downloadURL() {
                print(downloadedURL)
                let url = downloadedURL.absoluteString
               
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
                    "photoKey":url
                ]
                
                AppData.sharedInstance.treeNode
                    //            .child(AppData.sharedInstance.curUser!.uid)
                    .child(tree.treeName)
                    .setValue(treeDict)
            }
            
        })
    }
    
    private func saveUrl(url: URL) {
        tempUrl = url
    }
    
}


