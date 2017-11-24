


import Foundation

class Photo: NSObject {

    var userID = String()
    var photoURL : String
    var timeStamp = String()
    var isMain : Bool
    var photoID = String()
 
    init(URL: String) {
        self.userID = ""
        self.photoURL = URL
        let date = Date()
        let dateForm = DateFormatter()
        dateForm.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let dateStr = dateForm.string(from: date)
        self.timeStamp = dateStr
        self.isMain = false
        self.photoID = ""
    }
    
    
}
