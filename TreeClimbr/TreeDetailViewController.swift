import UIKit
import CoreLocation
import Firebase
import SDWebImage
import MapKit
import MessageUI


protocol MapFocusDelegate {
    func focusOnTree(location: CLLocationCoordinate2D, tree: Tree)
}

class TreeDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    
    var tree : Tree!
    var delegate : MapFocusDelegate?
    var rootSourceVC = ViewController()
    var sourceVC : TreeListViewController?
    var fromMapView : Bool = false
    var distance = Double()
    var photoObjArr = Array<Photo>()
    var imageArr = Array<UIImage>()
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //MARK: Outlets
    @IBOutlet var toMapButton: UIBarButtonItem!
    @IBOutlet weak var basicTreeInfoView: BasicTreeInfoView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var picturesView: UIView!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    lazy var aboutViewController: AboutViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is AboutViewController
        }) as! AboutViewController
    }()
    
    lazy var reviewViewController: CommentViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is CommentViewController
        }) as! CommentViewController
    }()
    
    lazy var photosViewController: PhotosViewController = {
        return childViewControllers.first(where: { (viewController) -> Bool in
            return viewController is PhotosViewController
        }) as! PhotosViewController
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 17.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        
        leftBarButtonItem.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 20)!], for: UIControlState.normal)
        rightBarButtonItem.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 20)!], for: UIControlState.normal)
        
        if let tree = tree {
            navigationBar.topItem?.title = tree.treeName
            
            basicTreeInfoView.treeNameLabel.text = tree.treeName
            
            self.tree.treeComments = []
            CommentManager.loadComments(tree: self.tree, completion: { (success) in
                self.basicTreeInfoView.commentLabel.text = "\(self.tree.treeComments.count) Comments"
                self.tree.treeComments = []
            })
            
            
            let url = tree.treePhotoURL
            
            basicTreeInfoView.backgroundImageView.sd_setImage(with: url,
                                                        completed: { (image, error, cacheType, url) in
                                                            print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
            })
            
            basicTreeInfoView.distanceLabel.text = "\(distanceFromUser()) km"
            basicTreeInfoView.favouritesCountLabel.text = "\(tree.treePopularity)"
            
            PhotoManager.loadPhotos(tree: tree, completion: { photos in
                
                guard let photos = photos else {
                    print("oops no photo object returned")
                    return
                }
                
                let storage = Storage.storage()
                let ref = storage.reference()
                
                let group = DispatchGroup()
                
                self.imageArr = []
                self.photoObjArr = []
                
                for photo in photos {
                    group.enter()
                    
                    let imagesRef = ref.child(photo.imageDBName)
                    
                    imagesRef.getData(maxSize: 1*1064*1064, completion: { data, error in
                        if let error = error {
                            print(error)
                            return
                        } else {
                            
                            let realImage = UIImage(data: data!)
                            
                            photo.image = realImage!
                            self.photoObjArr.append(photo)
                            group.leave()
                        }
                    })
                }
                
                group.notify(queue: DispatchQueue.global(qos: .background)) {
                    
                    DispatchQueue.main.async {
                        self.photosViewController.imageArr = []
                        self.photosViewController.photoObjArr = self.photoObjArr
                        self.photosViewController.photoObjArr.sort(by: { $0.timeStamp > $1.timeStamp })
                        for photo in self.photoObjArr {
                            self.imageArr.append(photo.image)
                        }
                        self.photosViewController.imageArr = self.imageArr
                        self.photosViewController.photoCollectionView.reloadData()
                    }
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
        aboutViewController.sourceVC = self
        reviewViewController.tree = tree
        photosViewController.tree = tree
        
        //setup view container for segmented control
        aboutView.isHidden = true
        reviewView.isHidden = true
        picturesView.isHidden = false
        
    }
    
    //MARK: Actions
    
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
        self.sourceVC?.tableView.reloadData()
    }
    
    
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (report) in
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            AlertShow.confirm(inpView: self, titleStr: "Delete Tree?", messageStr: " ", completion: {

                UserTreesManager.deleteUserTree(tree: self.tree, completion: { (true) in
                    FavouritesManager.loadFavourites(completion: { trees in
                    })
                    UserTreesManager.loadUserTrees(completion: { trees in
                        self.dismiss(animated: true, completion: {
                            self.sourceVC?.tableView.reloadData()
                        })
                    })
                })
            })
        }
        
        let blockAction = UIAlertAction(title: "Block", style: .default) { (block) in
            
        
            let badUser =  User(name: self.tree.treeCreatorName, email: "", uid: self.tree.treeCreator)
            AlertShow.confirm(inpView: self, titleStr: "Block \(self.tree.treeCreatorName)?", messageStr: "You won't see \(self.tree.treeCreatorName)'s trees, photos and comments anymore.", completion: {
                AppData.sharedInstance.hiddenUsersArr.append(badUser)
                HiddenUsersManager.addToHiddenUsersList(badUser: badUser, completion: {_ in
                })
                self.dismiss(animated: true, completion: {
                    self.sourceVC?.tableView.reloadData()
                })
            }
            )}
        
        alertController.addAction(cancelAction)
        
        if tree.treeCreator == Auth.auth().currentUser?.uid {
            alertController.addAction(deleteAction)
        } else {
            alertController.addAction(reportAction)
            if Auth.auth().currentUser != nil {
                alertController.addAction(blockAction)
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
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
    
    // MARK: MFMailComposeViewController
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["treeclimbrcontact@gmail.com"])
        mailComposerVC.setSubject("TreeClimbr - Inappropriate Content Report")
        mailComposerVC.setMessageBody("Found inappropriate content! \n\n Username: \n \(tree.treeCreatorName) \n\n TreeName: \n \(tree.treeName) \n\n TreeID: \n \(tree.treeID) \n ", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
