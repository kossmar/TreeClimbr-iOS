

import UIKit
import Firebase

class AboutViewController: UIViewController, VerifyUserDelegate {
    
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
    
    //MARK: Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let signUpVC = segue.destination as! SignUpViewController
        signUpVC.delegate = self
        signUpVC.sourceVC = self
    }
    
    //MARK: VerifyUserDelegate
    
    func verificationComplete() {
        addToFavourites(tree!)
    }
    
    // MARK: - Actions
    
    
    @IBAction func favouriteAction(_ sender: UIButton) {
        guard let tree = tree else {
            print("No tree object!")
            return
        }
        
        if ( Auth.auth().currentUser == nil ) {
            AlertShow.confirm(inpView: self, titleStr: "Account Required", messageStr: "You need an account to add a tree to favourites. Would you like to sign in?", completion: {
                self.performSegue(withIdentifier: "aboutToSignUp", sender: self)
            })
        } else {
            
            addToFavourites(tree)
        }
    }
    
    @IBAction func editTreeButton(_ sender: Any) {
        
    }
    
    //MARK: Custom Functions
    
    fileprivate func addToFavourites(_ tree: Tree) {
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
    
    
}
