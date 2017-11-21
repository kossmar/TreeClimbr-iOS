

import UIKit

class TreeDetailViewController: UIViewController {
    
    @IBOutlet weak var basicTreeInfoView: BasicTreeInfoView!
    var tree : Tree!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tree = tree {
            basicTreeInfoView.treeNameLabel.text = tree.treeName
        }else {
            print("You fucked it!")
        }
        //        contentView
        
        
        
        
    }
    
    
    
}
