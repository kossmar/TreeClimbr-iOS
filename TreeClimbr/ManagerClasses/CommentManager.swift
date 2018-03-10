

import UIKit
import Firebase

class CommentManager: NSObject {
    
    class func saveComment(comment: Comment, tree: Tree, completion: @escaping (Bool) -> Void) {
        
        if ( Auth.auth().currentUser == nil ) {
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
        
        let userCommentDict: [String : Any] = [
            "commentIDKey": comment.commentID,
            "treeIDKey": tree.treeID,
        ]
        
        AppData.sharedInstance.commentsNode
            .child(tree.treeID)
            .child(comment.commentID)
            .setValue(commentDict)
        
        AppData.sharedInstance.userCommentsNode
            .child(curUser.uid)
            .child(comment.commentID)
            .setValue(userCommentDict)
        
        completion(true)

    }
    
    class func loadComments(tree: Tree, completion: @escaping ([Comment]?) -> Void) {
        
//        if ( Auth.auth().currentUser == nil ) {
//            completion(nil)
//            return
//        }
        
        Database.database().reference()
            .child("comments")
            .child(tree.treeID)
            .observe( .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;

                if (value == nil) {
                    completion(nil)
                    return
                }
                
                AppData.sharedInstance.commentArr = Array<Comment>()
                

                for any in (value?.allValues)!
                {
//                let comments = snapshot
//                    .children
//                    .flatMap { $0 as? DataSnapshot }
//                    .flatMap { $0.value as? [String:Any] }
                
                print(any)
                
                // For each comment, change the associated name
//                for comment in comments {
                    
                    let comment : [String : Any] = any as! Dictionary <String, Any>
                    print(any)
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
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    /*
     }, withCancel: { (error) in
     return
     })
     }
     }) { (error) in
     print(error.localizedDescription)
     }
     */
    
    
    class func deleteComment(tree: Tree, comment: Comment) {
        
        guard let curUser = Auth.auth().currentUser else {return}
        
        AppData.sharedInstance.commentsNode
            .child(tree.treeID)
            .child(comment.commentID)
            .removeValue()
        
        AppData.sharedInstance.userCommentsNode
            .child(curUser.uid)
            .child(comment.commentID)
            .removeValue()
    }
    
    class func updateUserCommentsUserName(newName: String) {
        if ( Auth.auth().currentUser == nil ) {
//            completion(false)
            return
        }
        
        guard let curUser = Auth.auth().currentUser else {return}
        
        // Get all comments from one user
        Database.database().reference()
            .child("userComments")
            .child(curUser.uid)
            .observeSingleEvent(of: .value , with: { (snapshot) in
                let comments = snapshot
                    .children
                    .flatMap { $0 as? DataSnapshot }
                    .flatMap { $0.value as? [String:Any] }
                
                
                // For each comment, change the associated name
                for comment in comments {
                    let tree = comment["treeIDKey"] as! String
                    let commentID = comment["commentIDKey"] as! String
                    
                    // get comment information
                    AppData.sharedInstance.commentsNode
                        .child(tree)
                        .child(commentID)
                        .observeSingleEvent(of: .value, with: { (commentSnapshot) in
                            guard let commentDict = commentSnapshot.value as? NSDictionary else {return}
                            
                            let userID = commentDict["userIDKey"] as! String
                            let body = commentDict["bodyKey"] as! String
                            let timeStamp = commentDict["timeKey"] as! String
                            let commentID = commentDict["commentIDKey"] as! String
                            let _ = commentDict["usernameKey"] as! String
                            
                            // change username
                            let newCommentDict: [String : Any] = [
                                "userIDKey": userID,
                                "bodyKey": body,
                                "timeKey": timeStamp,
                                "commentIDKey": commentID,
                                "usernameKey": newName,
                                ]
                            
                            AppData.sharedInstance.commentsNode
                                .child(tree)
                                .child(commentID)
                                .setValue(newCommentDict)
                            
                        }, withCancel: { (error) in
                            return
                        })
                }
            }) { (error) in
                print(error.localizedDescription)
        }
    }
}



