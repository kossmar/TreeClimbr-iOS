

import UIKit
import CoreLocation
import Firebase
import SDWebImage

protocol MapFocusDelegate {
    func focusOnTree(location: CLLocationCoordinate2D)
}

class TreeDetailViewController: UIViewController {
    
    @IBOutlet var toMapButton: UIBarButtonItem!
    @IBOutlet weak var basicTreeInfoView: BasicTreeInfoView!
    var tree : Tree!
    var delegate : MapFocusDelegate?
    var rootSourceVC = ViewController()
    var fromMapView : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tree = tree {
            basicTreeInfoView.treeNameLabel.text = tree.treeName
            
            let url = tree.treePhotoURL

            basicTreeInfoView.treeImageView.sd_setImage(with: url,
                                                        completed: { (image, error, cacheType, url) in
                    print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
            })
            
        } else {
            print("ERROR")
        }
        if (fromMapView) {
            toMapButton.isEnabled = false
            toMapButton.tintColor = UIColor.clear
        }
    }
    
    @IBAction func toMapAction(_ sender: UIBarButtonItem) {
        let treeLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(tree.treeLatitude, tree.treeLongitude)
        self.delegate = rootSourceVC
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            self.rootSourceVC.focusOnTree(location: treeLocation)
        })
        
    }
    
    @IBAction func dismissDetailAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        fromMapView = false
        self.navigationItem.rightBarButtonItem = self.toMapButton
    }
    
}
