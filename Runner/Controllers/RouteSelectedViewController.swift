//
//  RouteSelectedViewController.swift
//  Runner
//
//  Created by Steven Mo on 7/26/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class RouteSelectedViewController: UIViewController, MKMapViewDelegate{

    //var latitudes: [Double]?
    //var longitudes: [Double]?
    var routeName = "CustomRoute"
    let dataDispatchGroup = DispatchGroup()
    
    @IBOutlet weak var routeMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLatitudes(nameOfRoute: routeName) { (latitude) in
            self.getLongitudes(nameOfRoute: self.routeName, completion: { (longitude) in
                self.displayPins(latitudes: latitude, longitudes: longitude)
                
                let location = CLLocationCoordinate2D(latitude: latitude[0], longitude: longitude[0])
                let span = MKCoordinateSpanMake(0.02, 0.02)
                let region = MKCoordinateRegionMake(location, span)
                self.routeMapView.setRegion(region, animated: true)
                
                if latitude.count > 1 {
                    for index in 0...latitude.count - 2 {
                        self.drawLine(latitude1: latitude[index], longitude1: longitude[index], latitude2: latitude[index + 1], longitude2: longitude[index + 1])
                    }
                }
            })
            DispatchQueue.main.async {
                
            }
        }
        navigationItem.title = routeName
    }
    
    func getLatitudes(nameOfRoute: String, completion: @escaping ([Double]) -> Void) {
        RouteService.getRouteLatitudes(routeName: nameOfRoute) { (latitudes) in
            completion(latitudes!)
        }
    }
    
    func getLongitudes(nameOfRoute: String, completion: @escaping ([Double]) -> Void) {
        RouteService.getRouteLongitudes(routeName: nameOfRoute) { (longitudes) in
            completion(longitudes!)
        }
    }
    
    func displayPins(latitudes : [Double], longitudes : [Double]) {
        for index in 0...(latitudes.count) - 1 {
            let coordinate = CLLocationCoordinate2D(latitude: latitudes[index], longitude: longitudes[index])
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            routeMapView.addAnnotation(annotation)
        }
    }
    
    func drawLine(latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double) {
        var coordinateArray = [CLLocationCoordinate2D]()
        coordinateArray.append(CLLocationCoordinate2DMake(latitude1, longitude1))
        coordinateArray.append(CLLocationCoordinate2DMake(latitude2, longitude2))
        
        let line = MKPolyline(coordinates: coordinateArray, count: 2)
        self.routeMapView.add(line)
        routeMapView.delegate = self
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
    
    @IBAction func cancelButtonTapped(_sender: Any) {
        self.performSegue(withIdentifier: "unwindToListRoutes", sender: nil)
    }
}

extension RouteSelectedViewController: DidTapCellProtocol {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToListRoutes" {
            let vc : ListRoutesTableViewController = segue.destination as! ListRoutesTableViewController
            vc.delegate = self
        }
    }
    
    func didTapCell(nameOfRoute: String) {
        self.routeName = nameOfRoute
        print("didTapCell")
    }
}
