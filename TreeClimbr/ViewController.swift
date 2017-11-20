

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var userCoordinate = CLLocationCoordinate2D()
    var myAnnotation = MKPointAnnotation()
    var treeLocation = CLLocationCoordinate2D()
    
//    var detailButton: UIButton = UIButton(type: UIButtonType.detailDisclosure) as UIButton
    
    var lat = 0.0
    var long = 0.0
    
    var treesArr = [Tree]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        ReadTrees.read()
//        setupAnnotations()
        setupTap()
        userLocationSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppData.sharedInstance.curUser == nil {
            performSegue(withIdentifier: "CheckIdentity", sender: self)
        }
    }
    
    
    //MARK: Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toNewTree" {
            guard let treeVC = segue.destination as? TreeNewViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            treeVC.coordinate = treeLocation
        }
        
//        if segue.identifier == "toTreeDetail" {
//            guard let treeDetailVC = segue.destination as? TreeDetailViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//            treeDetailVC.tree = tree
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let treesArr = AppData.sharedInstance.treesArr
        ReadTrees.read()
//        setupAnnotations()
        for tree in treesArr{
            let treeLat = tree.treeLatitude
            let treeLong = tree.treeLongitude
            let treeAnn = MKPointAnnotation()
            treeAnn.coordinate = CLLocationCoordinate2DMake(treeLat, treeLong)
            treeAnn.title = tree.treeName
            self.mapView.addAnnotation(treeAnn)
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = annCoordinates
        treeLocation = annCoordinates
        performSegue(withIdentifier: "toTreeDetail", sender: view)
        annotation.title = "MyTree" //title from tree new vc
        self.mapView.addAnnotation(annotation)
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
//    func setupAnnotations() {
//        for tree in AppData.sharedInstance.treesArr{
//            let treeLat = tree.treeLatitude
//            let treeLong = tree.treeLongitude
//            let treeAnn = MKPointAnnotation()
//            treeAnn.coordinate = CLLocationCoordinate2DMake(treeLat, treeLong)
//            treeAnn.title = tree.treeName
//            self.mapView.addAnnotation(treeAnn)
//        }
//        print("annotations added")
//    }
    
    
    //MARK: Map view delegate functions
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // go to tree creation
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation){
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomAnnotation")
        if annView == nil {
            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
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
            performSegue(withIdentifier: "toTreeDetail", sender: view)
        }
    }
    
    
}


