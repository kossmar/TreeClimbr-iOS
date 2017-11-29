

import UIKit
import Firebase


class PhotoManager: NSObject {
    
    class func savePhotos(photos: Array<Photo>, tree: Tree, completion: @escaping (Bool) -> Void) {
        
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
        
        
        let userID = Auth.auth().currentUser?.uid
        let userName = Auth.auth().currentUser?.displayName
        for photo in photos {
            
            let uuid = NSUUID().uuidString
            photo.photoID = uuid
            
            let photoDict: [String : Any] = [
                "userIDKey": userID!,
                "userNameKey": userName!,
                "urlKey": photo.photoURL,
                "timeKey": photo.timeStamp,
                "isMainKey": photo.isMain,
                "photoIDKey": photo.photoID,
                "imageDBNameKey": photo.imageDBName
            ]
            
            AppData.sharedInstance.photosNode
                .child(tree.treeID!)
                .child(photo.photoID)
                .setValue(photoDict)
            
        }

        completion(true)
        
    }
    
    class func loadPhotos(tree: Tree, completion: @escaping ([Photo]?) -> Void) {
        
        if ( Auth.auth().currentUser == nil ) {
            completion(nil)
            return
        }
        
        AppData.sharedInstance
            .photosNode.child(tree.treeID!)
//            .observe (.value, with: { (snapshot) in
            .observeSingleEvent(of: .value) { (snapshot) in

                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    completion(nil)
                    return
                }
                
                //                AppData.sharedInstance.treesArr = Array<Tree>()
                
                var tempPhotoArr = Array<Photo>()
                
                for any in (value?.allValues)!
                {
                    let photo : [String : Any] = any as! Dictionary <String, Any>
                    
                    let userID = photo["userIDKey"] as! String
                    let userName = photo["userNameKey"] as! String
                    let photoURL = photo["urlKey"] as! String
                    let timeStamp = photo["timeKey"] as! String
                    let isMain = photo["isMainKey"] as! Bool
                    let photoID = photo["photoIDKey"] as! String
                    let imageDB = photo["imageDBNameKey"] as! String
                    
                    let readPhoto = Photo(URL: photoURL)
                    readPhoto.userID = userID
                    readPhoto.userName = userName
                    readPhoto.isMain = isMain
                    readPhoto.timeStamp = timeStamp
                    readPhoto.photoID = photoID
                    readPhoto.imageDBName = imageDB
                    
                    tempPhotoArr.append(readPhoto)
                    
                    //                    print (AppData.sharedInstance.treesArr)
                    
                }
                
                print("\(#function) - \(AppData.sharedInstance.treesArr.count)")
                completion(tempPhotoArr)
            }
    }
    
    
}
