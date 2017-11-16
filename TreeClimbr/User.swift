import Foundation
import RealmSwift

class User : Object {
    @objc dynamic var userId = ""
    @objc dynamic var userName = ""
    
    let trees = LinkingObjects(fromType: Tree.self, property: "user")
}

