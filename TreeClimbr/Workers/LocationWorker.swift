//
//  LocationWorker.swift
//  TreeClimbr
//
//  Created by Mar Koss on 2019-08-02.
//  Copyright © 2019 Mar Koss. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class LocationWorker: CLLocationManager, CLLocationManagerDelegate
{
    func userLocationSetup()
    {
        self.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            self.desiredAccuracy = kCLLocationAccuracyBest
            self.distanceFilter = 0.1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        userCoordinate = myLocation
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
//        mapView.setRegion(region, animated: true)
//        mapView.showsUserLocation = true
        self.stopUpdatingLocation()
        // TODO: Send region and user location to Map Scene somehow
    }
    
    func centerToUser(location: MKUserLocation) -> MKCoordinateRegion
    {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        return region
    }
}
