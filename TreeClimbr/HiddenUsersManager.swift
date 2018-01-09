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
    
    
    class func removeFromHidden(badUser: User) {
        
        AppData.sharedInstance.hiddenUsersNode
            .child(Auth.auth().currentUser!.uid)
            .child("\(badUser.uid)")
            .removeValue()
        
    }
    
}
