

import UIKit
import Firebase

class SaveComment: NSObject {
    
    class func saveComment(comment: Comment, tree: Tree, completion: @escaping (Bool) -> Void) {
        
        if ( Auth.auth().currentUser == nil )
        {
            return
        }
        
        
        let userID = Auth.auth().currentUser?.uid
        
        let commentDict: [String : Any] = [
            "userIDKey": userID,
            "bodyKey": comment.body,
            "timeKey": comment.timeStamp,
            "commentIDKey": comment.commentID
        ]
        
        AppData.sharedInstance.treeNode
            .child(tree.treeID!)
            .child(comment.commentID)
            .setValue(treeDict)
        
        completion(true)

    }
}


