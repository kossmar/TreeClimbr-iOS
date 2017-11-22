import UIKit
import CoreLocation
import Firebase
import SDWebImage
import MapKit


protocol MapFocusDelegate {
    func focusOnTree(location: CLLocationCoordinate2D, tree: Tree)
}

class TreeDetailViewController: UIViewController {
    
    @IBOutlet var toMapButton: UIBarButtonItem!
    @IBOutlet weak var basicTreeInfoView: BasicTreeInfoView!
    var tree : Tree!
    var delegate : MapFocusDelegate?
    var rootSourceVC = ViewController()
    var fromMapView : Bool = false
    var distance = Double()
    
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
            
            let url = tree.treePhotoURL

            basicTreeInfoView.treeImageView.sd_setImage(with: url,
                                                        completed: { (image, error, cacheType, url) in
                    print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
            })
            
          basicTreeInfoView.distanceLabel.text = "\(distanceFromUser()) km"
         
        } else {

            print("ERROR")
        }
        if (fromMapView) {
            toMapButton.isEnabled = false
            toMapButton.tintColor = UIColor.clear
        }
        
        //setup child viewcontrollers
        aboutViewController.tree = tree
        
        //setup view container for segmented control
        aboutView.isHidden = true
        reviewView.isHidden = true
        picturesView.isHidden = false
    }
    
    @IBAction func toMapAction(_ sender: UIBarButtonItem) {
        let treeLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(tree.treeLatitude, tree.treeLongitude)
        self.delegate = rootSourceVC
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            self.rootSourceVC.focusOnTree(location: treeLocation, tree: self.tree)
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
            aboutView.isHidden = true
            reviewView.isHidden = true
            picturesView.isHidden = false
            break
        case 1:
            aboutView.isHidden = true
            reviewView.isHidden = false
            picturesView.isHidden = true
            break
        case 2:
            aboutView.isHidden = false
            reviewView.isHidden = true
            picturesView.isHidden = true
            break
        default:
            aboutView.isHidden = true
            reviewView.isHidden = true
            picturesView.isHidden = false
            break
        }
    }
    
    
    

    func distanceFromUser() -> Double {
        let treeLocation = CLLocationCoordinate2DMake(tree.treeLatitude,tree.treeLongitude)
        let currentLocation = rootSourceVC.userCoordinate
        let treePoint = MKMapPointForCoordinate(treeLocation)
        let currentPoint = MKMapPointForCoordinate(currentLocation)
        let distance = (MKMetersBetweenMapPoints(treePoint, currentPoint) / 1000)
        let distanceRound = Double(round(10*distance)/10)
        return distanceRound
    }
    

//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        <#code#>
//    }
    
    
}
