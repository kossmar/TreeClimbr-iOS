import Foundation
import Firebase

class HiddenUsersManager: NSObject {
    
    
    
    //This is to block a user and prevent photos/comments of specified users from showing up on a user’s app
    class func addToHiddenUsersList(badUser: User, completion: @escaping (Bool) -> Void) {
        
        
        if ( Auth.auth().currentUser == nil )
        {
            completion(false)
            return
        }
        
        let hiddenUsersDict: [String: Any] = [
            "badUserIDKey": badUser.uid
        ]
        
        AppData.sharedInstance.hiddenUsersNode
            .child(Auth.auth().currentUser!.uid)
            .child(badUser.uid)
            .setValue(hiddenUsersDict)
        
        completion(true)
    }
    
    class func loadHiddenUsers(completion: @escaping ([User]?) -> Void) {
        
        if ( Auth.auth().currentUser == nil ) {
            completion(nil)
            return
        }
        
        AppData.sharedInstance.hiddenUsersArr.removeAll()
        
        AppData.sharedInstance.hiddenUsersNode
            .child(Auth.auth().currentUser!.uid)
            .observeSingleEvent(of: .value, with: { (hiddenUsersSnapshot) in
                
                
                let allHiddenUsers = hiddenUsersSnapshot.value as? [String: Any]
                
                if (allHiddenUsers == nil) {
                    completion(nil)
                    return
                }
                
                for badUser in (allHiddenUsers?.keys)!
                {
                    
                    AppData.sharedInstance
                        .usersNode
                        .child(badUser)
                        .observeSingleEvent (of: .value, with: { (usersSnapshot) in
                            
                            let usersDict = usersSnapshot.value as? [String: Any]
                            
                            if usersDict == nil
                            {
                                completion(nil)
                                return
                            }
                            
                            let userName : String = usersDict?["nameKey"] as! String
                            let userEmail = usersDict?["emailKey"] as! String
                            let userID = usersDict?["uidKey"] as! String
                            
                            let badUser = User(name: userName, email: userEmail, uid: userID)
                            
                            AppData.sharedInstance.hiddenUsersArr.append(badUser)
                            //TODO: remove print
                            print (" After Append\(AppData.sharedInstance.hiddenUsersArr.count)")
                            
                        })
                }
                
                print("\(#function) - \(AppData.sharedInstance.hiddenUsersArr.count)")
                completion(AppData.sharedInstance.hiddenUsersArr)
            })
        
    }
    
    
    class func removeFromHidden(badUser: User, completion: @escaping (Bool) -> Void) {
        
        AppData.sharedInstance.hiddenUsersNode
            .child(Auth.auth().currentUser!.uid)
            .child("\(badUser.uid)")
            .removeValue()
        
        completion(true)
        
    }
    
//        class func loadHiddenUsers(completion: @escaping ([User]?) -> Void)
    
    class func hideBlockedUsersComments(array: [Comment]) -> [Comment] {
        
        var hiddenUIDSet = Set <String>()
        var tempArray = array
        
        for hiddenUser in AppData.sharedInstance.hiddenUsersArr {
            hiddenUIDSet.insert(hiddenUser.uid)
        }
        
        var index = 0
        for comment in tempArray {
            if hiddenUIDSet.contains(comment.userID) {
                tempArray.remove(at: index)
            } else {
                index += 1
            }
        }
        return tempArray
    }
    
    class func hideBlockedUsersPhotos(array: [Photo]) -> [Photo] {
        
        var hiddenUIDSet = Set <String>()
        var tempArray = array
        
        for hiddenUser in AppData.sharedInstance.hiddenUsersArr {
            hiddenUIDSet.insert(hiddenUser.uid)
        }
        
        var index = 0
        for comment in tempArray {
            if hiddenUIDSet.contains(comment.userID) {
                tempArray.remove(at: index)
            } else {
                index += 1
            }
        }
        return tempArray
    }
    
}
