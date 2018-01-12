

import UIKit
import Firebase

class AboutViewController: UIViewController {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var treeDescTextView: UITextView!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var addFavouriteButton: UIButton!
    @IBOutlet weak var editTreeButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!
    
    var sourceVC = TreeDetailViewController()
    var favouriteState = false

    var tree : Tree? {
        didSet {
            guard let tree = tree else { return }
            treeDescTextView.text = tree.treeDescription
            coordinateLabel.text = "\(tree.treeLatitude), \(tree.treeLongitude)"

            if tree.treeDescription == "" {
                self.treeDescTextView.text = "\(tree.treeCreatorName) did not love me enough. So... no description..."
                self.treeDescTextView.textColor = UIColor.gray
            }
            
            self.userLabel.text = tree.treeCreatorName
            
            for thisTree in AppData.sharedInstance.favouritesArr {
                if tree.treeID == thisTree.treeID {
                    favouriteState = true
                    addFavouriteButton.setTitle("Remove From Favourites", for: .normal)
                    break
                }
            }
            
            if tree.treeCreator == Auth.auth().currentUser?.uid {
//                editTreeButton.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        treeDescTextView.isEditable = false
        addFavouriteButton.layer.cornerRadius = addFavouriteButton.frame.height/8
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        editTreeButton.layer.cornerRadius = editTreeButton.frame.height/8

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       treeDescTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    // MARK: - Actions
    
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
            addFavouriteButton.setTitle("Remove From Favourites", for: .normal)
        }
        else {
            FavouritesManager.removeFavourite(tree: tree)
            tree.treePopularity -= 1
            let favourites = String(describing: tree.treePopularity)
            self.sourceVC.basicTreeInfoView.favouritesCountLabel.text = favourites
            SaveTree.updateTree(tree: tree, completion: { success in
            })
            favouriteState = false
            addFavouriteButton.setTitle("Add To Favourites", for: .normal)
        }
        FavouritesManager.loadFavourites {trees in
        }
        ReadTrees.read { trees in
        }
        UserTreesManager.loadUserTrees { trees in
        }
    }
    
    @IBAction func editTreeButton(_ sender: Any) {
        
    }
    
    
}
