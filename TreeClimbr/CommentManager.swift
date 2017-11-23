

import UIKit
import Firebase

class CommentManager: NSObject {
    
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
            .setValue(commentDict)
        
        completion(true)

    }
    
    class func loadComments(tree: Tree, completion: @escaping ([Comment]) -> Void) {
        
        AppData.sharedInstance
            .treeNode.child(tree.treeID)
            .observe (.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    completion(nil)
                    return
                }
                
//                AppData.sharedInstance.treesArr = Array<Tree>()
                
                
                for any in (value?.allValues)!
                {
                    let comment : [String : Any] = any as! Dictionary <String, Any>
                    
                    let userID = comment["userIDKey"] as! String
                    let body = comment["bodyKey"] as! String
                    let timeStamp = ["timeKey"] as! Date
                    let commentID = ["commentIDKey"] as! String
                    
                    
                    let readComment = Comment(body: body)
                    readComment.commentID = commentID
                    readComment.userID = userID
                    readComment.timeStamp = timeStamp

                    
                    AppData.sharedInstance.treesArr.append(readComment)
                    
                    //                    print (AppData.sharedInstance.treesArr)
                    
                }
                
                print("\(#function) - \(AppData.sharedInstance.treesArr.count)")
                completion(AppData.sharedInstance.treesArr)
            })
    }
}


