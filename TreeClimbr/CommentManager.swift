

import UIKit
import Firebase

class CommentManager: NSObject {
    
    class func saveComment(comment: Comment, tree: Tree, completion: @escaping (Bool) -> Void) {
        
        if ( Auth.auth().currentUser == nil )
        {
            completion(false)
            return
        }
        
        guard let curUser = Auth.auth().currentUser else {return}
        
        comment.commentID = "\(curUser.uid)" + "\(comment.timeStamp)"
        
        let commentDict: [String : Any] = [
            "userIDKey": curUser.uid,
            "usernameKey": curUser.displayName!,
            "bodyKey": comment.body,
            "timeKey": comment.timeStamp,
            "commentIDKey": comment.commentID,
        ]
        
        AppData.sharedInstance.commentsNode
            .child(tree.treeID)
            .child(comment.commentID)
            .setValue(commentDict)
        
        completion(true)

    }
    
    class func loadComments(tree: Tree, completion: @escaping ([Comment]?) -> Void) {
        
//        if ( Auth.auth().currentUser == nil ) {
//            completion(nil)
//            return
//        }
        
        AppData.sharedInstance
            .commentsNode.child(tree.treeID)
            .observe (.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;
                
                if (value == nil) {
                    completion(nil)
                    return
                }
                
                AppData.sharedInstance.commentArr = Array<Comment>()
                
                
                for any in (value?.allValues)!
                {
                    let comment : [String : Any] = any as! Dictionary <String, Any>
                    
                    let userID = comment["userIDKey"] as! String
                    let body = comment["bodyKey"] as! String
                    let timeStamp = comment["timeKey"] as! String
                    let commentID = comment["commentIDKey"] as! String
                    let username = comment["usernameKey"] as! String
                    
                    
                    let readComment = Comment(body: body)
                    readComment.commentID = commentID
                    readComment.userID = userID
                    readComment.timeStamp = timeStamp
                    readComment.username = username

                    
                    AppData.sharedInstance.commentArr.append(readComment)
                    tree.treeComments.append(readComment)

                }
                
                print("\(#function) - \(AppData.sharedInstance.commentArr.count)")
                completion(AppData.sharedInstance.commentArr)
            })
    }
    
    class func deleteComment(tree: Tree, comment: Comment) {
        AppData.sharedInstance.commentsNode
            .child(tree.treeID)
            .child(comment.commentID)
            .removeValue()
    }
    
}


