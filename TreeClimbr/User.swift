import Foundation

class User: NSObject, NSCoding {
    var name: String
    var email: String
    var uid: String
    var favouritesArr = Array<String>()
    
    init(name:String,  email:String, uid:String)
    {
        self.name = name;
        self.email = email;
        self.uid = uid;
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let name = aDecoder.decodeObject(forKey: "nameKey") as! String;
        let email = aDecoder.decodeObject(forKey: "emailKey") as! String;
        let uid = aDecoder.decodeObject(forKey: "uidKey") as! String;
        
        self.init(name: name, email: email, uid: uid)
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: "nameKey");
        aCoder.encode(self.email, forKey: "emailKey");
        aCoder.encode(self.uid, forKey: "uidKey");
    }
    
}

