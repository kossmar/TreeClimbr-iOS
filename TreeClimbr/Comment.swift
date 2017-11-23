
import Foundation
import Firebase

class Comment: NSObject {

    var body = String()
    var timeStamp : String
    var userID = String()
    var commentID = String()
    
    init(body: String) {
        let date = Date()
        let dateForm = DateFormatter()
        dateForm.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateStr = dateForm.string(from: date)
        
        self.body = body
        self.timeStamp = dateStr
        self.userID = Auth.auth().currentUser!.uid // This should be the commenter's user id
        self.commentID = "\(self.userID)" + "\(self.timeStamp)"
    }
    
}
