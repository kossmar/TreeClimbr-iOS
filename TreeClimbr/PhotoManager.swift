

import UIKit
import Firebase


class PhotoManager: NSObject {
    
    class func savePhotos(photos: Array<Photo>, tree: Tree, completion: @escaping (Bool) -> Void) {
        
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
        
        guard let curUser = Auth.auth().currentUser else {return}
        
        let userID = curUser.uid
        let userName = curUser.displayName!
        for photo in photos {
            
            let uuid = NSUUID().uuidString
            photo.photoID = uuid
            
            let photoDict: [String : Any] = [
                "userIDKey": userID,
                "userNameKey": userName,
                "urlKey": photo.photoURL,
                "timeKey": photo.timeStamp,
                "isMainKey": photo.isMain,
                "photoIDKey": photo.photoID,
                "imageDBNameKey": photo.imageDBName
            ]
            
            let userPhotoDict: [String : Any] = [
                "photoIDKey": photo.photoID,
                "parentTreeKey": tree.treeID
            ]
            
            AppData.sharedInstance.photosNode
                .child(tree.treeID)
                .child(photo.photoID)
                .setValue(photoDict)
            
            AppData.sharedInstance.userPhotosNode
                .child(userID)
                .child(photo.photoID)
                .setValue(userPhotoDict)
        }

        completion(true)
        
    }
    
    class func loadPhotos(tree: Tree, completion: @escaping ([Photo]?) -> Void) {
        
        AppData.sharedInstance.photosNode
            .child(tree.treeID)
            .observeSingleEvent(of: .value) { (snapshot) in

                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    completion(nil)
                    return
                }
                
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
                }
                
                print("\(#function) - \(AppData.sharedInstance.treesArr.count)")
                completion(tempPhotoArr)
            }
    }
    
    class func deletePhoto(photo: Photo, tree: Tree) {
        
        AppData.sharedInstance.photosNode
            .child(tree.treeID)
            .child(photo.photoID)
            .removeValue()
        
        AppData.sharedInstance.userPhotosNode
            .child(tree.treeCreator)
            .child(photo.photoID)
            .removeValue()
        
        let desertRef = AppData.sharedInstance.storageRef.child(photo.imageDBName)
        
        desertRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("PHOTO DELETED")
            }
        }
        
    }
    
    class func updateUserPhotosUserName(newName: String) {
        if ( Auth.auth().currentUser == nil ) {
            //            completion(false)
            return
        }
        
        guard let curUser = Auth.auth().currentUser else {return}
        
        // Get all comments from one user
            AppData.sharedInstance.userPhotosNode
            .child(curUser.uid)
            .observeSingleEvent(of: .value , with: { (snapshot) in
                let photos = snapshot
                    .children
                    .flatMap { $0 as? DataSnapshot }
                    .flatMap { $0.value as? [String:Any] }
                
                // For each photo, change the associated name
                for photo in photos {
                    let tree = photo["parentTreeKey"] as! String
                    let photoID = photo["photoIDKey"] as! String
                    
                    // get comment information
                    AppData.sharedInstance.photosNode
                        .child(tree)
                        .child(photoID)
                        .observeSingleEvent(of: .value, with: { (photoSnapshot) in
                            guard let photoDict = photoSnapshot.value as? NSDictionary else {return}
                            
                            let userID = photoDict["userIDKey"] as! String
                            let _ = photoDict["userNameKey"] as! String
                            let photoURL = photoDict["urlKey"] as! String
                            let timeStamp = photoDict["timeKey"] as! String
                            let isMain = photoDict["isMainKey"] as! Bool
                            let photoID = photoDict["photoIDKey"] as! String
                            let imageDBName = photoDict["imageDBNameKey"] as! String
                            
                            
                            // change username
                            let newPhotoDict: [String : Any] = [
                                "userIDKey": userID,
                                "userNameKey": newName,
                                "urlKey": photoURL,
                                "timeKey": timeStamp,
                                "isMainKey": isMain,
                                "photoIDKey": photoID,
                                "imageDBNameKey": imageDBName
                                ]
                            
                            AppData.sharedInstance.photosNode
                                .child(tree)
                                .child(photoID)
                                .setValue(newPhotoDict)
                            
                        }, withCancel: { (error) in
                            return
                        })
                }
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
}
