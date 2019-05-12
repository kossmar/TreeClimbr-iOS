import Foundation
import Firebase

class Tree: NSObject {
    var treeID: String
    var treeName: String
    var treeSpecies: String?
    var treeRating: Double? = 0.0
    var treeDescription: String?
    var treeHowToFind: String?
    var treeLatitude = Double()
    var treeLongitude = Double()
    var treePopularity: Int = 0
    var treePhotoData: NSData?
    var treePhotoURL: URL
    var treeCreator: String
    var treeCreatorName: String
    var treeComments = Array<Comment>()
    var distFromUser = Double()
    var isHidden = Bool()
    
    init(name: String, description: String?, treeLat: Double, treeLong: Double, photo: NSData?) {

        
        self.treeName = name
        self.treeID = self.treeName + "|" + String(describing: Date()) + "1"
        self.treeSpecies = "none"
        self.treeRating = 0.0
        self.treeDescription = description
        self.treeHowToFind = "none"
        self.treeLatitude = treeLat
        self.treeLongitude = treeLong
        self.treePopularity = 0
        self.treePhotoData = photo
        self.treePhotoURL = URL(string:"https://firebasestorage.googleapis.com/v0/b/climbr-f1fe2.appspot.com/o/defaultPhoto.png?alt=media&token=1ee322e5-7309-4cc1-9edf-f7ccbaccd356")!
        self.treeCreator = "creator"
        self.treeCreatorName = "creatorName"
    }
    
}
