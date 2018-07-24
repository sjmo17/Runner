//
//  Route.swift
//  
//
//  Created by Steven Mo on 7/24/18.
//

import Foundation
import MapKit
import CoreLocation
import FirebaseDatabase

class Route {
    var name: String
    var distance: Double
    var location: CGPoint
    var points: [CGPoint]
    
    init(name: String, distance: Double, location: CGPoint, points: [CGPoint]) {
        self.name = name
        self.distance = distance
        self.location = location
        self.points = points
    }
}
