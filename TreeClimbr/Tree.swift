import Foundation

class Tree {
    @objc dynamic var treeId = ""
    @objc dynamic var treeName = ""
    @objc dynamic var treeSpecies = ""
    @objc dynamic var treeRating = 0.0
    @objc dynamic var treeDescription = ""
    @objc dynamic var treeHowToFind = ""
    @objc dynamic var treeLatitude = 0.0
    @objc dynamic var treeLongitude = 0.0
    @objc dynamic var treePopularity = 0
    //We will have to save photos as NSData
    @objc dynamic var treePhotoData: NSData? = nil


}

