import XCTest
@testable import TreeClimbr

class TreeTests: XCTestCase {
    
   // var tree: Tree!
    var trees: [Tree] = []
    
    override func setUp() {
         super.setUp()
        
        let bundle = Bundle(for: TreeTests.self)
        loadTreeSamples("TreeSamples", in: bundle)
    }
    
    func testTreeHasExpectedDefaultValues() {
        
        let sampleTree = trees[0]
        
        
        XCTAssert(sampleTree.treeName == "Victoria Annex View", "A sample tree didn't have expected name")
    }
    
    func loadTreeSamples(_ plistName: String, in bundle: Bundle) {
        trees = []
        
        if let path = bundle.path(forResource: plistName, ofType: "plist"){
            if let arrayOfDictionaries = NSArray(contentsOfFile: path){
                for dict in arrayOfDictionaries {
                   var tree = [String : Any] ()
                    tree = dict as! [String : Any]
                    
                    let treeID = tree["idKey"] as! String
                    let treeDescription = tree["descriptionKey"] as! String
                    let treeHowToFind = tree["howToFindKey"] as! String
                    let treeLatitude = tree["latitudeKey"] as! Double
                    let treeLongitude = tree["longitudeKey"]  as! Double
                    let treeName : String = tree["nameKey"] as! String
                    let treePopularity = tree["popularityKey"] as! Int
                    let treeRating = tree["ratingKey"] as! Double
                    let treeSpecies : String = tree["speciesKey"] as! String
                    let treePhotoStr = tree["photoKey"] as! String
                    let treeCreator = tree["creatorKey"] as! String
                    let treeCreatorName = tree["creatorNameKey"] as! String
                    let treePhotoURL = URL(string: treePhotoStr)
                    
                    let readTree = Tree(name: treeName,
                                        description: treeDescription,
                                        treeLat: treeLatitude,
                                        treeLong: treeLongitude,
                                        photo: nil)
                    
                    
                    let treeRat = Double(treeRating)
                    let treePop = Int(treePopularity)
                    readTree.treeSpecies = treeSpecies
                    readTree.treeRating = treeRat
                    readTree.treeHowToFind = treeHowToFind
                    readTree.treePopularity = treePop
                    readTree.treePhotoURL = treePhotoURL!
                    readTree.treeID = treeID
                    readTree.treeCreator = treeCreator
                    readTree.treeCreatorName = treeCreatorName
                    
                    trees.append(readTree)
                }
            }
        }
        
    }
    
}
