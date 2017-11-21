

import UIKit
import CoreLocation

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
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var picturesView: UIView!
    
    lazy var aboutViewController: AboutViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is AboutViewController
        }) as! AboutViewController
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tree = tree {
            basicTreeInfoView.treeNameLabel.text = tree.treeName
        }else {
            print("ERROR")
        }
        if (fromMapView) {
            toMapButton.isEnabled = false
            toMapButton.tintColor = UIColor.clear
        }
        
        //setup child viewcontrollers
        aboutViewController.tree = tree
        
        //setup view container for segmented control
        aboutView.isHidden = false
        reviewView.isHidden = true
        picturesView.isHidden = true
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
    
    //MARK: Segment Control

    @IBAction func switchViewAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            aboutView.isHidden = false
            reviewView.isHidden = true
            picturesView.isHidden = true
            break
        case 1:
            aboutView.isHidden = true
            reviewView.isHidden = false
            picturesView.isHidden = true
            break
        case 2:
            aboutView.isHidden = true
            reviewView.isHidden = true
            picturesView.isHidden = false
            break
        default:
            aboutView.isHidden = false
            reviewView.isHidden = true
            picturesView.isHidden = true
            break
        }
    }
    
    
    
}
