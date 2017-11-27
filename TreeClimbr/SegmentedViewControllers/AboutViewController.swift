

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var treeDescTextView: UITextView!
    @IBOutlet weak var coordinateLabel: UILabel!
    
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
        FavouritesManager.saveFavourite(tree: self.tree!) { success in
            return
        }
    }

}
