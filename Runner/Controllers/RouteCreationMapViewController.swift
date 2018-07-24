//
//  RouteCreationMapViewController.swift
//  Runner
//
//  Created by Steven Mo on 7/24/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

protocol RouteCreationMapProtocol {
    func handleTap(gestureRecognizer: UITapGestureRecognizer)
}

class RouteCreationMapViewController: UIViewController {

    var latitudes = [Double]()
    var longitudes = [Double]()
    
    @IBOutlet weak var routeMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let location = CLLocationCoordinate2D(latitude: 37.773514, longitude: -122.417807)
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(location, span)
        routeMap.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Make School"
        annotation.subtitle = "School for developers"
        
        routeMap.addAnnotation(annotation)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        var distance = 0.0;
        
        for index in 0...latitudes.count - 1 {
            let firstCoord = CLLocation(latitude: latitudes[index], longitude: longitudes[index])
            if index + 1 == latitudes.count {
                let secondCoord =  CLLocation(latitude: latitudes[0], longitude: longitudes[0])
                distance += firstCoord.distance(from: secondCoord)
            } else {
                let secondCoord = CLLocation(latitude: latitudes[index + 1], longitude: longitudes[index + 1])
                distance += firstCoord.distance(from: secondCoord)
            }
        }
        distance = distance / 1609.344
        
        RouteService.createRoute(name: "testRoute1", latitudes: latitudes, longitudes: longitudes, distance: distance)
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: routeMap)
        let coordinate = routeMap.convert(location,toCoordinateFrom: routeMap)
        
        latitudes.append(coordinate.latitude)
        longitudes.append(coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        routeMap.addAnnotation(annotation)
    }
}
