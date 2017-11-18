import Foundation

class Tree: NSObject {
//    var treeId: String?
    var treeName: String
    var treeSpecies: String?
    var treeRating: Double? = 0.0
    var treeDescription: String?
    var treeHowToFind: String?
    var treeLatitude = Double()
    var treeLongitude = Double()
    var treePopularity: Int? = 0
    var treePhotoData: NSData
    
    
    init(name: String, description: String?, treeLat: Double, treeLong: Double, photo: NSData) {
      //  self.treeId = ""
        self.treeName = name
        self.treeSpecies = "none"
        self.treeRating = 0.0
        self.treeDescription = description
        self.treeHowToFind = "none"
        self.treeLatitude = treeLat
        self.treeLongitude = treeLong
        self.treePopularity = 0
        self.treePhotoData = photo
    }
    
}
