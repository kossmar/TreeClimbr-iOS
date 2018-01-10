import Foundation
import Firebase
import FirebaseDatabase

class AppData: NSObject {
    
    static let sharedInstance = AppData()
    
    public var curUser: User!
    
    public var usersNode: DatabaseReference
    public var treeNode: DatabaseReference
    public var commentsNode: DatabaseReference
    public var favouritesNode: DatabaseReference
    public var photosNode: DatabaseReference
    public var userTreesNode: DatabaseReference
    public var storageRef: StorageReference
    public var blockedNode: DatabaseReference
    public var hiddenUsersNode: DatabaseReference
    
    public var treesArr : Array <Tree> = Array <Tree> ()
    public var commentArr = Array <Comment> ()
    public var favouritesArr = Array <Tree> ()
    public var userTreesArr = Array <Tree> ()
    public var hiddenUsersArr = Array <User> ()
    
    
    
    public override init()
    {
        
        usersNode = Database.database().reference().child("users")
        treeNode = Database.database().reference().child("trees")
        commentsNode = Database.database().reference().child("comments")
        favouritesNode = Database.database().reference().child("favourites")
        photosNode = Database.database().reference().child("photos")
        userTreesNode = Database.database().reference().child("userTrees")
        storageRef = Storage.storage().reference()
        blockedNode = Database.database().reference().child("blocked")
        hiddenUsersNode = Database.database().reference().child("hiddenUsers")
    }
    
    
    
    
}

