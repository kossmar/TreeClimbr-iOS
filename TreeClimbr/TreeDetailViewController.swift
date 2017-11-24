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
    var photoObjArr = Array<Photo>()
    var imageArr = Array<UIImage>()
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var picturesView: UIView!
    
    lazy var aboutViewController: AboutViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is AboutViewController
        }) as! AboutViewController
    }()
    
    lazy var reviewViewController: ReviewViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is ReviewViewController
        }) as! ReviewViewController
    }()
    
    lazy var photosViewController: PhotosViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is PhotosViewController
        }) as! PhotosViewController
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
            
            PhotoManager.loadPhotos(tree: tree, completion: { photos in
                
                guard let photos = photos else {
                    print("oops no photo object returned")
                    return
                }
                
                let storage = Storage.storage()
                let ref = storage.reference()

                
                let group = DispatchGroup()
                
                
                for photo in photos {
                    group.enter()
                   // let imagesRef = ref.child(tree.treeID!)
                 //   let dbref = tree.treeName + "|" + photo.timeStamp
                    
                    let imagesRef = ref.child(photo.imageDBName)
                    
                   imagesRef.getData(maxSize: 1*1064*1064, completion: { data, error in
                        if let error = error {
                            print(error)
                            return
                        } else {
                            
                            let realImage = UIImage(data: data!)
                            self.imageArr.append(realImage!)
                            group.leave()
                    }
                        
                    

                    })
                }
                
                group.notify(queue: DispatchQueue.global(qos: .background)) {
                    self.photosViewController.imageArr = self.imageArr
        //            self.photosViewController.photoCollectionView.reloadData()
                }
                
            })
            
        } else {
            
            print("ERROR")
        }
        if (fromMapView) {
            toMapButton.isEnabled = false
            toMapButton.tintColor = UIColor.clear
        }
        
        //setup child viewcontrollers
        aboutViewController.tree = tree
        reviewViewController.tree = tree
        photosViewController.tree = tree
        
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.photosViewController.photoCollectionView.reloadData()
    }
    
}
