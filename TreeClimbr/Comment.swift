
import Foundation

class Comment: NSObject {

    var body = String()
    var timeStamp : Date
    var userID = String()
    
    init(body: String) {
        self.body = body
        self.timeStamp = Date()
        self.userID = AppData.sharedInstance.curUser.uid
    }
    
}
