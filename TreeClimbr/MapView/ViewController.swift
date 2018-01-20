import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MapFocusDelegate {

    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var userCoordinate = CLLocationCoordinate2D()
    var myAnnotation = MKPointAnnotation()
    var treeLocation = CLLocationCoordinate2D()
    
    @IBOutlet weak var addTreeToLocationButton: UIButton!
    @IBOutlet weak var treeListButton: UIButton!
    
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var lat = 0.0
    var long = 0.0
    
    var treesArr = [Tree]()
    
    @IBOutlet weak var sideButtonsView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    //MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup side buttons
        sideButtonsView.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
        sideButtonsView.layer.cornerRadius = sideButtonsView.frame.height/2
        sideButtonsView.isHidden = true
        
        
        setupTap()
        userLocationSetup()        
        
        FavouritesManager.loadFavourites { (success) in
            return
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapViewWillStartLoadingMap(self.mapView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard let someHandle = handle else {return}
        Auth.auth().removeStateDidChangeListener(someHandle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        handle = Auth.auth().addStateDidChangeListener { auth, user in
//            if user == nil {
//                self.addTreeToLocationButton.isEnabled = false
//                print("No user signed in")
//
//            } else {
//                self.addTreeToLocationButton.isEnabled = true
//            }
//        }
        
        
        let blockedUser = AppData.sharedInstance.blockedNode
        let user = Auth.auth().currentUser?.uid
        
        blockedUser.observeSingleEvent(of: .value, with: { (snapshot) in
            if user != nil {
                if snapshot.hasChild(user!) {
                    do {
                        try Auth.auth().signOut()
                        self.performSegue(withIdentifier: "CheckIdentity", sender: self)
                    }
                    catch let error as NSError {
                        print (error.localizedDescription)
                    }
                }
            }
        })

        
        FavouritesManager.loadFavourites { (success) in
            return
        }
        
        HiddenUsersManager.loadHiddenUsers { (success) in
            return
        }
        
        

        emailIsVerified()
    }
    
    
    //MARK: Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toNewTree" {
            guard let treeVC = segue.destination as? TreeNewViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeVC.coordinate = treeLocation
            treeVC.sourceVC = self
        }
        
        if segue.identifier == "toTreeDetail" {
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
        
        if segue.identifier == "toTreeList" {
            guard let treeListVC = segue.destination as? TreeListViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeListVC.sourceVC = self
        }
        
        if segue.identifier == "CheckIdentity" {
            guard let signUpVC = segue.destination as? SignUpViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            signUpVC.sourceVC = self
        }
    }
    
    //MARK: Tap gesture methods
    func setupTap() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(locationLongPressed(longPressGestureRecognizer:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    @objc func locationLongPressed(longPressGestureRecognizer: UILongPressGestureRecognizer){
        
        let touchPoint = longPressGestureRecognizer.location(in: self.mapView)
        let annCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        treeLocation = annCoordinates
        self.performSegue(withIdentifier: "toNewTree", sender: self.view)


    }
    
    
    
    //MARK: Setup map features
    
    @IBAction func login(_ sender: UIButton) {
        performSegue(withIdentifier: "CheckIdentity", sender: self.view)
    }
    
    func userLocationSetup() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 0.1
            locationManager.delegate = self
            mapView.delegate = self
        }
        
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func centerToUser(_ sender: UIButton) {
        let location = mapView.userLocation
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.userTrackingMode = .follow
        
    }
    
    @IBAction func addTreeToUserLoc(_ sender: UIButton){
        treeLocation = userCoordinate
        performSegue(withIdentifier: "toNewTree", sender: view)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        userCoordinate = myLocation
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
        
        if sideButtonsView.isHidden {
            
            UIView.transition(with: sideButtonsView,
                              duration: 0.3,
                              options: .transitionFlipFromLeft,
                              animations: {
                                self.sideButtonsView.isHidden = false
                                }, completion: nil)
            
            
            UIView.animate(withDuration: 0.3) {
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
    
    //MARK: Map view delegate functions
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // go to tree creation


    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is TreeAnnotation){
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomAnnotation")
        if annView == nil {
            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
//            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
            annView!.canShowCallout = true
            //add info button
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let cusView = view.annotation as! TreeAnnotation
            let treeObject = cusView.tree
            performSegue(withIdentifier: "toTreeDetail", sender: treeObject)
        }
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        
        AppData.sharedInstance.treesArr = self.hideBlockedTrees()
        
        ReadTrees.read(completion: { trees in

            guard
                let trees = trees
                else { return }

            for tree in self.treesArr {
                let treeLat = tree.treeLatitude
                let treeLong = tree.treeLongitude
                let treeAnn: TreeAnnotation = TreeAnnotation()
                treeAnn.coordinate = CLLocationCoordinate2DMake(treeLat, treeLong)
                treeAnn.title = tree.treeName
                treeAnn.tree = tree
                
                self.mapView.addAnnotation(treeAnn)

            }
        })
    }
    
    // MARK: - Delegate Functions
    
    func focusOnTree(location: CLLocationCoordinate2D, tree: Tree) {
    
//        mapView.setCenter(location, animated: true)
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)

        mapView.setRegion(region, animated: true)
    
    }
    
    func emailIsVerified() {
        
        let user = Auth.auth().currentUser
        user?.reload()
        if let loggedinUser = user, let _ = user?.isEmailVerified {
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
        
        for hiddenUser in AppData.sharedInstance.hiddenUsersArr {
            hiddenUIDSet.insert(hiddenUser.uid)
        }
        
        var index = 0
        for aTree in treesArr {
            if hiddenUIDSet.contains(aTree.treeCreator) {
                treesArr.remove(at: index)
            } else {
                index += 1
            }
        }
        return treesArr
    }


}


