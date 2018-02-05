import CoreLocation
import Foundation
import Firebase
import UIKit
import MapKit

class TreeManager: NSObject {

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
}

    

