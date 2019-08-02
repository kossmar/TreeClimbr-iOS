import UIKit
import MapKit
import CoreLocation
import Firebase

protocol MapDisplayLogic: class
{
}

class MapViewController: UIViewController, MapDisplayLogic, CLLocationManagerDelegate

{    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addTreeToLocationButton: UIButton!
    @IBOutlet weak var treeListButton: UIButton!
    @IBOutlet weak var sideButtonsView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    var interactor: MapBusinessLogic?
    var router: (NSObjectProtocol & MapRoutingLogic & MapDataPassing)?
    
    // TODO: Extract CoreLocation functions to a single LocationWorker Class!!
    var locationManager = CLLocationManager()
    // move the user coordinate to the LocationWorker
    var userCoordinate = CLLocationCoordinate2D()
    // move these to the dataStore
    var myAnnotation = MKPointAnnotation()
    var treeLocation = CLLocationCoordinate2D()
    
    var justOnce = true
    var handle: AuthStateDidChangeListenerHandle?

    // TODO: Delete these
//    var lat = 0.0
//    var long = 0.0
    
    // TODO: this seems like the wrong way to handle this data. Look into it more but for the time being move it to the dataStore
    var treesArr = [Tree]()
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = MapInteractor()
        let presenter = MapPresenter()
        let router = MapRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    
    //MARK: ViewController lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // change these with functional Programming??
        //setup side buttons
        sideButtonsView.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
        sideButtonsView.layer.cornerRadius = sideButtonsView.frame.height/2
        sideButtonsView.isHidden = true
        
        
        setupTap()
        // remove userLocationSetup() and run it when the app starts
        userLocationSetup()        
        
        // TODO: definitely move this. What is it even doing? Loading trees to a singleton? Shouldn't be in the VC!!
        FavouritesManager.loadFavourites { (success) in
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapViewWillStartLoadingMap(self.mapView)
        
        // Exctract logic into worker through interactor. VC just needs to know to launch the Alert View
        if Auth.auth().currentUser == nil && justOnce {
            AlertShow.show(inpView: self, titleStr: "Careful out there!", messageStr: "Tree climbing can be dangerous. Always follow local laws and practice extreme caution when attempting to climb trees!")
            justOnce = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(true)
        
        AppUtility.lockOrientation(.all)
        guard let someHandle = handle else {return}
        
        // TODO: Extract this out of VC
        Auth.auth().removeStateDidChangeListener(someHandle)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        
        
        // TODO: Definitely move this out of the VC. maybe into the blockedUserManager. Consider combining that with the other managers somehow.
        let blockedUser = AppData.sharedInstance.blockedNode
        let user = Auth.auth().currentUser?.uid
        
        blockedUser.observeSingleEvent(of: .value, with: { (snapshot) in
            if user != nil {
                if snapshot.hasChild(user!)
                {
                    do
                    {
                        try Auth.auth().signOut()
                        self.performSegue(withIdentifier: "CheckIdentity", sender: self)
                    }
                    catch let error as NSError {
                        print (error.localizedDescription)
                    }
                }
            }
        })

        // TODO: Move this to a worker
        FavouritesManager.loadFavourites { (success) in
            return
        }
        
        // TODO: Move this to a worker
        HiddenUsersManager.loadHiddenUsers { (success) in
            return
        }
        
        // TODO: Move this to a worker
        emailIsVerified()
    }
    
    
    // MARK: Routing
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if let scene = segue.identifier {
//            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
//            if let router = router, router.responds(to: selector) {
//                router.perform(selector, with: segue)
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "toNewTree"
        {
            guard let treeVC = segue.destination as? TreeNewViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeVC.coordinate = treeLocation
            treeVC.fromMap = true
        }
        
        if segue.identifier == "toTreeDetail"
        {
            guard let treeDetailVC = segue.destination as? TreeDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeDetailVC.rootSourceVC = self

            let treeObject = sender as! Tree
            treeDetailVC.tree = treeObject
            treeDetailVC.fromMapView = true
            
            treeObject.treeComments = []
            CommentManager.loadComments(tree: treeObject, completion: { (success) in
                treeDetailVC.basicTreeInfoView.commentLabel.text = "\(treeObject.treeComments.count) Comments"
                treeObject.treeComments = []
            })
        }
        
        if segue.identifier == "toTreeList"
        {
            guard let treeListVC = segue.destination as? TreeListViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeListVC.sourceVC = self
        }
        
        if segue.identifier == "CheckIdentity"
        {
            guard let signUpVC = segue.destination as? SignUpViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            signUpVC.sourceVC = self
        }
    }
    
    //MARK: Tap gesture methods
    
    func setupTap()
    {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(locationLongPressed(longPressGestureRecognizer:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func locationLongPressed(longPressGestureRecognizer: UILongPressGestureRecognizer)
    {
        
        let touchPoint = longPressGestureRecognizer.location(in: self.mapView)
        let annCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        treeLocation = annCoordinates
        self.performSegue(withIdentifier: "toNewTree", sender: self.view)
    }
    
    //MARK: Setup map features
    

    // TODO: Delete this after testing functionality. It's being moved to an isolated LocationManager class
    func userLocationSetup()
    {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 0.1
            locationManager.delegate = self
            mapView.delegate = self
        }
        
        locationManager.startUpdatingLocation()
    }
    
    // TODO: Delete this after testing functionality. It's being moved to an isolated LocationManager class
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        userCoordinate = myLocation
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Actions
    
    @IBAction func login(_ sender: UIButton)
    {
        performSegue(withIdentifier: "CheckIdentity", sender: self.view)
    }
    
    // TODO: this function is being extracted into a LocationWorker class. this IBAction should tell the interactor to ask the LocationWorker for the region
    @IBAction func centerToUser(_ sender: UIButton)
    {
        let location = mapView.userLocation
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.userTrackingMode = .follow
    }
    
    @IBAction func addTreeToUserLoc(_ sender: UIButton)
    {
        treeLocation = userCoordinate
        performSegue(withIdentifier: "toNewTree", sender: view)
    }
    
    @IBAction func menuButton(_ sender: UIButton)
    {
        
        if sideButtonsView.isHidden
        {
            UIView.transition(with: sideButtonsView,
                              duration: 0.3,
                              options: .transitionFlipFromLeft,
                              animations: {
                                self.sideButtonsView.isHidden = false
                                }, completion: nil)
            
            
            UIView.animate(withDuration: 0.3)
            {
                self.menuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        } else {
            UIView.transition(with: sideButtonsView,
                              duration: 0.3,
                              options: .transitionFlipFromLeft,
                              animations: {
                                self.sideButtonsView.isHidden = true
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3) {
                self.menuButton.transform = CGAffineTransform.identity
                self.sideButtonsView.transform = CGAffineTransform.identity
            }
        }
    }
    
    // TODO: exctract this to a worked from the interactor
    func emailIsVerified()
    {
        let user = Auth.auth().currentUser
        user?.reload()
        if let loggedinUser = user, let _ = user?.isEmailVerified
        {
            if loggedinUser.isEmailVerified == false {
                let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email?", preferredStyle: .alert)
                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                    (_) in
                    user?.sendEmailVerification(completion: nil)
                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertVC.addAction(alertActionOkay)
                alertVC.addAction(alertActionCancel)
                self.present(alertVC, animated: true, completion: nil) }
        } else {
            print ("Email verified. Signing in...")
        }
    }
    
    func hideBlockedTrees() -> [Tree]{
        var hiddenUIDSet = Set <String>()
        
        treesArr = AppData.sharedInstance.treesArr
        
        for hiddenUser in AppData.sharedInstance.hiddenUsersArr
        {
            hiddenUIDSet.insert(hiddenUser.uid)
        }
        
        var index = 0
        for aTree in treesArr
        {
            if hiddenUIDSet.contains(aTree.treeCreator)
            {
                treesArr.remove(at: index)
            } else {
                index += 1
            }
        }
        return treesArr
    }
}

extension MapViewController: MKMapViewDelegate
{
    
    // TODO: Move all of this to a worked through the interactor. All the ViewController needs to know about is the resulting MKAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is TreeAnnotation)
        {
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomAnnotation")
        if annView == nil
        {
            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
            annView!.canShowCallout = true
            let detailButton: UIButton = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            annView!.rightCalloutAccessoryView = detailButton
        } else {
            annView!.annotation = annotation
        }
        
        annView!.image = #imageLiteral(resourceName: "CustomAnnotation")
        let size = annView!.image!.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        annView!.image!.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annView!.image = scaledImage
        return annView!
    }
    
    // TODO: Where does this get moved to?
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView
        {
            let cusView = view.annotation as! TreeAnnotation
            let treeObject = cusView.tree
            performSegue(withIdentifier: "toTreeDetail", sender: treeObject)
        }
    }
    
    // TODO: Move this a worked through the interactor. All the VC needs to know about is the array of TreeAnnotations
    func mapViewWillStartLoadingMap(_ mapView: MKMapView)
    {
        
        AppData.sharedInstance.treesArr = self.hideBlockedTrees()
        
        TreeManager.read {
            
            for tree in self.treesArr
            {
                let treeLat = tree.treeLatitude
                let treeLong = tree.treeLongitude
                let treeAnn: TreeAnnotation = TreeAnnotation()
                treeAnn.coordinate = CLLocationCoordinate2DMake(treeLat, treeLong)
                treeAnn.title = tree.treeName
                treeAnn.tree = tree
                
                self.mapView.addAnnotation(treeAnn)
            }
        }
    }
}

extension MapViewController: MapFocusDelegate
{
    // TODO: Exctract this function. All the VC needs to know about is the region
    func focusOnTree(location: CLLocationCoordinate2D, tree: Tree)
    {
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
    }
}


