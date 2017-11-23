import Foundation
import Firebase
import FirebaseDatabase

class AppData: NSObject {
    
    static let sharedInstance = AppData()
    
    public var curUser: User!

    public var usersNode: DatabaseReference
    public var treeNode: DatabaseReference
    
    public var treesArr : Array <Tree> = Array <Tree> ()
    public var commentArr = Array <Comment> ()
    

    public override init()
    {
//        FirebaseApp.configure()
        
        usersNode = Database.database().reference().child("users")
        treeNode = Database.database().reference().child("trees")
        commentNode = treeNode.child("comment")
    }
    
    
    

}
