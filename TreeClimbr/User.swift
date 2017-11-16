import Foundation

class User: NSObject {
    var name: String = ""
    var email: String = ""
    var uid: String = ""
    
    init(name:String,  email:String, uid:String)
    {
        self.name = name;
        self.email = email;
        self.uid = uid;
    }
}

