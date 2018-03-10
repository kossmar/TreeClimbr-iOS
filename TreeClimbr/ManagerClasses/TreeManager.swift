import CoreLocation
import Foundation
import Firebase
import UIKit
import MapKit

class TreeManager: NSObject {

    var tempUrl: URL!
    
    class func deleteTree(tree: Tree, completion: @escaping (Bool) -> Void) {
        
        deleteImagesFromStorage(tree)
        deleteUserComments(tree)
        deleteUserPhotos(tree)
        
        AppData.sharedInstance.treeNode
            .child(tree.treeID)
            .removeValue()
        
        AppData.sharedInstance.userTreesNode
            .child(Auth.auth().currentUser!.uid)
            .child(tree.treeID)
            .removeValue()
        
        AppData.sharedInstance.favouritesNode
            .child(Auth.auth().currentUser!.uid)
            .child(tree.treeID)
            .removeValue()
        
        AppData.sharedInstance.commentsNode
            .child(tree.treeID)
            .removeValue()
        
        
        completion(true)
    }
    
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
    
    class func updateUserTreesUserName(newName: String) {
        if ( Auth.auth().currentUser == nil ) {
            //            completion(false)
            return
        }
        
        guard let curUser = Auth.auth().currentUser else {return}
        
        // Get all comments from one user
        AppData.sharedInstance.userTreesNode
            .child(curUser.uid)
            .observeSingleEvent(of: .value , with: { (snapshot) in
                let trees = snapshot
                    .children
                    .flatMap { $0 as? DataSnapshot }
                    .flatMap { $0.value as? [String:Any] }
                
                // For each photo, change the associated name
                for tree in trees {

                    let treeID = tree["treeIDKey"] as! String
                    
                    // get comment information
                    AppData.sharedInstance.treeNode
                        .child(treeID)
                        .observeSingleEvent(of: .value, with: { (treeSnapshot) in
                            guard let treeDict = treeSnapshot.value as? NSDictionary else {return}
                            
                            let treeID = treeDict["idKey"] as! String
                            let treeDescription = treeDict["descriptionKey"] as! String
                            let treeHowToFind = treeDict["howToFindKey"] as! String
                            let treeLatitude = treeDict["latitudeKey"] as! Double
                            let treeLongitude = treeDict["longitudeKey"]  as! Double
                            let treeName = treeDict["nameKey"] as! String
                            let treePopularity = treeDict["popularityKey"] as! Int
                            let treeRating = treeDict["ratingKey"] as! Double
                            let treeSpecies = treeDict["speciesKey"] as! String
                            let treePhotoURL = treeDict["photoKey"] as! String
                            let treeCreator = treeDict["creatorKey"] as! String
                            let _ = treeDict["creatorNameKey"] as! String
                            
                            // change username
                            let newTreeDict: [String : Any] = [
                                "idKey": treeID,
                                "nameKey": treeName,
                                "descriptionKey": treeDescription,
                                "speciesKey": treeSpecies,
                                "ratingKey": treeRating,
                                "howToFindKey": treeHowToFind,
                                "latitudeKey": treeLatitude,
                                "longitudeKey": treeLongitude,
                                "popularityKey": treePopularity,
                                "photoKey": treePhotoURL,
                                "creatorKey": treeCreator,
                                "creatorNameKey": newName,
                                ]
                            
                            AppData.sharedInstance.treeNode
                                .child(treeID)
                                .setValue(newTreeDict)
                            
                        }, withCancel: { (error) in
                            return
                        })
                }
            }) { (error) in
                print(error.localizedDescription)
        }
    }

    
    class func read(completion: @escaping ([Tree]?) -> Void) {
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
    
    //MARK: Private Functions
    
    fileprivate static func deleteUserComments(_ tree: Tree) {
        // Get all comments from one user
        AppData.sharedInstance.commentsNode
            .child(tree.treeID)
            .observeSingleEvent(of: .value , with: { (snapshot) in
                let comments = snapshot
                    .children
                    .flatMap { $0 as? DataSnapshot }
                    .flatMap { $0.value as? [String:Any] }
                
                for comment in comments {
                    let userIDKey = comment["userIDKey"] as! String
                    let commentID = comment["commentIDKey"] as! String
                    
                    AppData.sharedInstance.userCommentsNode
                        .child(userIDKey)
                        .child(commentID)
                        .removeValue()
                }
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    fileprivate static func deleteUserPhotos(_ tree: Tree) {
        // Get all comments from one user
        AppData.sharedInstance.photosNode
            .child(tree.treeID)
            .observeSingleEvent(of: .value , with: { (snapshot) in
                let photos = snapshot
                    .children
                    .flatMap { $0 as? DataSnapshot }
                    .flatMap { $0.value as? [String:Any] }
                
                for photo in photos {
                    let userIDKey = photo["userIDKey"] as! String
                    let photoID = photo["photoIDKey"] as! String
                    
                    AppData.sharedInstance.userPhotosNode
                        .child(userIDKey)
                        .child(photoID)
                        .removeValue()
                }
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    fileprivate static func deleteImagesFromStorage(_ tree: Tree) {
        // Get all photos from one tree
        AppData.sharedInstance.photosNode
            .child(tree.treeID)
            .observeSingleEvent(of: .value , with: { (snapshot) in
                let treePhotos = snapshot
                    .children
                    .flatMap { $0 as? DataSnapshot }
                    .flatMap { $0.value as? [String:Any] }
                                
                // For each photo, delete the image from storage
                for photo in treePhotos {
                    
                    let imageDBName = photo["imageDBNameKey"] as! String
                    let desertRef = AppData.sharedInstance.storageRef.child(imageDBName)
                    
                    desertRef.delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("PHOTO DELETED")
                        }
                    }
                }
                
                AppData.sharedInstance.photosNode
                    .child(tree.treeID)
                    .removeValue()
            })
    }
    
}

    

