//
//  ViewController.swift
//  TreeClimbr
//
//  Created by Mar Koss on 2017-11-15.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var userCoordinate = CLLocationCoordinate2D()
    var myAnnotation = MKPointAnnotation()
    
    var lat = 0.0
    var long = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTap()
        userLocationSetup()
        
    }
    
    //MARK: Tap gesture methods
    func setupTap() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(locationTapped(tapGestureRecognizer:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    

    @objc func locationLongPressed(longPressGestureRecognizer: UILongPressGestureRecognizer){
        let nameAlertCon = UIAlertController(title: "Name Entry", message: "Enter a name for your tree!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        nameAlertCon.addTextField(configurationHandler: nil)
        let touchPoint = longPressGestureRecognizer.location(in: self.mapView)
        let annCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default)
        { (action) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = annCoordinates
            annotation.title = nameAlertCon.textFields?.first?.text
            self.mapView.addAnnotation(annotation)
        }
        nameAlertCon.addAction(confirmAction)
        nameAlertCon.addAction(cancelAction)
        self.present(nameAlertCon, animated: true, completion: nil)
    }
    
    func userLocationSetup() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 0.1
            locationManager.delegate = self
        }
        
        locationManager.startUpdatingLocation()
        
        //TEST STUFF
//        let location : CLLocationCoordinate2D = locationManager.location!.coordinate
//        lat = location.latitude
//        long = location.longitude
//
//        myAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        myAnnotation.title = "MY TREE"
//        myAnnotation.subtitle = "🌴🌴🌴🌴🌴"
//        mapView.addAnnotation(myAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    

    
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
}

