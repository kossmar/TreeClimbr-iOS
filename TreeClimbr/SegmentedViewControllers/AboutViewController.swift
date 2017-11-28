

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var treeDescTextView: UITextView!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var addFavouriteButton: UIButton!
    
    var sourceVC = TreeDetailViewController()
    var favouriteState = false
    var tree : Tree? {
        didSet {
            guard let tree = tree else { return }
            treeDescTextView.text = tree.treeDescription
            coordinateLabel.text = "\(tree.treeLatitude), \(tree.treeLongitude)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        treeDescTextView.isEditable = false
        userLabel.text = "By: Me"
        

        
        
    }
    
    @IBAction func favouriteAction(_ sender: UIButton) {
        guard let tree = tree else {
            print("No tree object!")
            return
        }
        
        if favouriteState == false {
            
            FavouritesManager.saveFavourite(tree: tree) { success in
                tree.treePopularity += 1
                let favourites = String(describing: tree.treePopularity)
                self.sourceVC.basicTreeInfoView.favouritesCountLabel.text = favourites
                SaveTree.updateTree(tree: tree, completion: { success in
                })
                return
            }
            
            favouriteState = true
            addFavouriteButton.titleLabel?.text = "Remove From Favourites"
        }
        else {
            FavouritesManager.removeFavourite(tree: tree)
            tree.treePopularity -= 1
            let favourites = String(describing: tree.treePopularity)
            self.sourceVC.basicTreeInfoView.favouritesCountLabel.text = favourites
            favouriteState = false
            addFavouriteButton.titleLabel?.text = "Add To Favourites"
        }
    }
}
