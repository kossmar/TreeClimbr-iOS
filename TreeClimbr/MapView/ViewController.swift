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
    
    var handle: AuthStateDidChangeListenerHandle?
    
    //    var detailButton: UIButton = UIButton(type: UIButtonType.detailDisclosure) as UIButton

    var lat = 0.0
    var long = 0.0
    
    var treesArr = [Tree]()
    
    @IBOutlet weak var sideButtonsView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
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
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.performSegue(withIdentifier: "CheckIdentity", sender: self)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FavouritesManager.loadFavourites { (success) in
            return
        }
        mapView.removeAnnotations(mapView.annotations)
        
        ReadTrees.read(completion: { trees in
            
            guard
                let trees = trees
                else { return }
            
            for tree in trees {
                let treeLat = tree.treeLatitude
                let treeLong = tree.treeLongitude
                let treeAnn : TreeAnnotation = TreeAnnotation()
                treeAnn.coordinate = CLLocationCoordinate2DMake(treeLat, treeLong)
                treeAnn.title = tree.treeName
                treeAnn.tree = tree
                self.mapView.addAnnotation(treeAnn)
            }
        })
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
        performSegue(withIdentifier: "toNewTree", sender: view)

    }
    
    //MARK: Setup map features
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
        
        ReadTrees.read(completion: { trees in
            
            guard
                let trees = trees
                else { return }
            
            for tree in trees {
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
    
        let matching = mapView.annotations.first { (annotation) -> Bool in
            
            if let annotation = annotation as? TreeAnnotation {
                return annotation.tree.treePhotoURL == tree.treePhotoURL
            }
            
            return false
        }
        
        if let match = matching {
            
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
            mapView.selectAnnotation(match, animated: true)
            
//            mapView.showAnnotations([match], animated: true)
        }
    }

    
}


