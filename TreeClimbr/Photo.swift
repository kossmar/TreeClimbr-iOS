


import Foundation

class Photo: NSObject {

    var userID = String()
    var photoURL : URL
    var timeStamp: Date
    var isMain : Bool
 
    init(URL: URL) {
        self.userID = AppData.sharedInstance.curUser.uid
        self.photoURL = URL
        self.timeStamp = Date()
        self.isMain = false
    }
    
    
}
