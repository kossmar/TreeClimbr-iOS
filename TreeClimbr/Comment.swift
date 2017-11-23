
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
        dateForm.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let dateStr = dateForm.string(from: date)
        
        self.body = body
        self.timeStamp = dateStr
        self.userID = Auth.auth().currentUser!.uid
        self.commentID = "\(self.userID)" + "\(self.timeStamp)"
    }
    
}
