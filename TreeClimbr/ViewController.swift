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
    
    @objc func locationTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let touchPoint = tapGestureRecognizer.location(in: mapView)
        let annCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = annCoordinates
        mapView.addAnnotation(annotation)
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
    
}

