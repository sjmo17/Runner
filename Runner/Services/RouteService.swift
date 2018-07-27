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
    
    static func getRouteLatitudes(routeName: String, completion: @escaping ([Double]?) -> Void) {
        let ref = Database.database().reference().child("routes").child(routeName).child("latitudes")
        
        var latitudesArray = [Double]()
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for index in 0..<value.count {
                    let key = "pin\(index)"
                    let latitudeValue = value[key] as? Double ?? 0.0
                    latitudesArray.append(latitudeValue)
                }
            }
            print(latitudesArray)
            if latitudesArray.count > 0 {
                completion(latitudesArray)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getRouteLongitudes(routeName: String, completion: @escaping ([Double]?) -> Void) {
        let ref = Database.database().reference().child("routes").child(routeName).child("longitudes")
        
        var longitudesArray = [Double]()
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for index in 0..<value.count {
                    let key = "pin\(index)"
                    let longitudeValue = value[key] as? Double ?? 0.0
                    longitudesArray.append(longitudeValue)
                }
            }
            print(longitudesArray)
            if longitudesArray.count > 0 {
                completion(longitudesArray)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getAllRouteNames(completion: @escaping ([String]?, [Double]?) -> Void) {
        let ref = Database.database().reference().child("routes")
        
        var returnRouteNames = [String]()
        var returnDistance = [Double]()
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let allChildren = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion(nil, nil)}
            
            for child in allChildren {
                returnRouteNames.append(child.key)
                
                let insideChild = child.value as? [String : Any]
                if let inside = insideChild {
                    let distance = inside["distance"]
                    returnDistance.append(distance as! Double)
                }
            }
            
            if returnRouteNames.count > 0 {
                completion (returnRouteNames, returnDistance)
            } else {
                return completion(nil, nil)
            }
        }
    }
}
