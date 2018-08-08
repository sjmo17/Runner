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
import FirebaseAuth

protocol RouteCreationMapProtocol {
    func handleTap(gestureRecognizer: UITapGestureRecognizer)
}

class RouteCreationMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var latitudes = [Double]()
    var longitudes = [Double]()
    var routeName = "Custom Route"
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var routeMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // latitude and longitude of user's current location
        let userLocation = routeMap.userLocation
        let userCoordinate = userLocation.coordinate
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(userCoordinate, span)
        routeMap.setRegion(region, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        routeMap.showsUserLocation = true
        routeMap.delegate = self
        
        showInputDialog()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appMapViewMemoryFix()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        appMapViewMemoryFix()
//    }
    
    func appMapViewMemoryFix() {
        routeMap.showsUserLocation = false
        routeMap.delegate = nil
        routeMap.removeFromSuperview()
        routeMap = nil
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if latitudes.count > 1 {
            let distance = calculateDistance()
            guard let firUser = Auth.auth().currentUser else { return }
            UserService.getUsername(firUser) { (name) in
                RouteService.createRoute(firUser, name: "\(name ?? "")_\(self.routeName)", latitudes: self.latitudes, longitudes: self.longitudes, distance: distance)
            }
        }
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: routeMap)
        let coordinate = routeMap.convert(location,toCoordinateFrom: routeMap)
        
        latitudes.append(coordinate.latitude)
        longitudes.append(coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        routeMap.addAnnotation(annotation)
        
        if latitudes.count > 1 {
            for index in 0...latitudes.count - 2 {
                drawLine(latitude1: latitudes[index], longitude1: longitudes[index], latitude2: latitudes[index + 1], longitude2: longitudes[index + 1])
            }
        }
    }
    
    func calculateDistance() -> Double {
        var distance = 0.0;
        
        for index in 0...latitudes.count - 2 {
            let firstCoord = CLLocation(latitude: latitudes[index], longitude: longitudes[index])
            let secondCoord = CLLocation(latitude: latitudes[index + 1], longitude: longitudes[index + 1])
            distance += firstCoord.distance(from: secondCoord)
        }
        distance = distance / 1609.344
        return distance
    }
    
    func showInputDialog() {
        let alertController = UIAlertController(title: "Route Name", message: "Give a name to your custom route. (No special characters.)", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            let name = alertController.textFields?[0].text
            self?.routeName = name!
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter a name"
        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func drawLine(latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double) {
        var coordinateArray = [CLLocationCoordinate2D]()
        coordinateArray.append(CLLocationCoordinate2DMake(latitude1, longitude1))
        coordinateArray.append(CLLocationCoordinate2DMake(latitude2, longitude2))
        
        let line = MKPolyline(coordinates: coordinateArray, count: 2)
        self.routeMap.add(line)
        routeMap.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .red //UIColor(red: 184, green: 202, blue: 237, alpha: 255)
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.routeMap.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        let region = MKCoordinateRegionMake(mapView.userLocation.coordinate, span)
//        mapView.setRegion(region, animated: true)
//    }
}
