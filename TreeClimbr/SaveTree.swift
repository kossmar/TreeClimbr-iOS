import UIKit
import Firebase


class SaveTree: NSObject {

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
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = imagesRef.putData(photoData, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { snapshot in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
        
        imagesRef.putData(tree.treePhotoData as Data, metadata: nil)
        
        
        

        
        
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
            "photoKey":photoID
        ]

        AppData.sharedInstance.treeNode
//            .child(AppData.sharedInstance.curUser!.uid)
            .child(tree.treeName)
            .setValue(treeDict)
    }
    
}


