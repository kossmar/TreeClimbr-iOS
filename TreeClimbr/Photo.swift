


import Foundation
import UIKit

class Photo: NSObject {

    var userID = String()
    var userName = String()
    var photoURL : String
    var timeStamp = String()
    var isMain : Bool
    var photoID = String()
    var imageDBName = String()
    var image = UIImage()
 
    init(URL: String) {
        self.userName = "fakeName"
        self.userID = "fakeID"
        self.photoURL = URL
        let date = Date()
        let dateForm = DateFormatter()
        dateForm.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let dateStr = dateForm.string(from: date)
        self.timeStamp = dateStr
        self.isMain = false
        self.photoID = "fakeID"
        self.imageDBName = ""
    }
    
    
}
