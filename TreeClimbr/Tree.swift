import Foundation

class Tree: NSObject {
    var treeId: String
    var treeName: String
    var treeSpecies: String?
    var treeRating: Double? = 0.0
    var treeDescription: String?
    var treeHowToFind: String?
    var treeLatitude: Double = 0.0
    var treeLongitude: Double = 0.0
    var treePopularity: Int? = 0
    var treePhotoData: NSData
    
    init(id: String, name: String, species: String?, rating: Double?, description: String?, howTofind: String?, treeLat: Double, treeLong: Double, popularity: Int?, photo: NSData) {
        self.treeId = id
        self.treeName = name
        self.treeSpecies = species
        self.treeRating = rating
        self.treeDescription = description
        self.treeHowToFind = howTofind
        self.treeLatitude = treeLat
        self.treeLongitude = treeLong
        self.treePopularity = popularity
        self.treePhotoData = photo
    }
}
