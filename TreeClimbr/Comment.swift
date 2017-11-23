
import Foundation

class Comment: NSObject {

    var body = String()
    var timeStamp : Date
    var userID = String()
    var commentID = String()
    
    init(body: String) {
        self.body = body
        self.timeStamp = Date()
        self.userID = AppData.sharedInstance.curUser.uid
        self.commentID = "\(self.userID)" + "\(self.timeStamp)"
    }
    
}
