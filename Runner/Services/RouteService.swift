//
//  RouteService.swift
//  Runner
//
//  Created by Steven Mo on 7/24/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import FirebaseDatabase

struct RouteService { // FIREBASE
    static func createRoute(name: String, latitudes: [Double], longitudes: [Double], distance: Double) {
        let latRef = Database.database().reference().child("routes").child(name).child("latitudes")
        let longRef = Database.database().reference().child("routes").child(name).child("longitudes")
        
        var latDict = [String : Double]()
        var longDict = [String : Double]()
        
        for index in 0...latitudes.count - 1 {
            latDict["pin\(index)"] = latitudes[index]
        }
        for index in 0...longitudes.count - 1 {
            longDict["pin\(index)"] = longitudes[index]
        }
        
        latRef.updateChildValues(latDict)
        longRef.updateChildValues(longDict)
        
        let distRef = Database.database().reference().child("routes").child(name)
        distRef.updateChildValues(["distance" : distance])
    }
}
