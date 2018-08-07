//
//  UserService.swift
//  Runner
//
//  Created by Steven Mo on 7/30/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = [Constants.Keys.username : username,
                         Constants.Keys.miles_run : 0.0,
                         Constants.Keys.runs : 0] as [String : Any]
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func getMilesRun(_ firUser: FIRUser, completion: @escaping (Double?) -> Void) {
        var returnMilesRun = 0.0
        
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let insideChild = snapshot.value as? [String : Any]
            if let inside = insideChild {
                let milesRun = inside[Constants.Keys.miles_run]
                returnMilesRun = milesRun as! Double
            }
            
            if returnMilesRun != 0.0 {
                completion (returnMilesRun)
            } else {
                return completion(0.0)
            }
        }
    }
    
    static func getTotalRuns(_ firUser: FIRUser, completion: @escaping (Int?) -> Void) {
        var returnTotalRuns = 0
        
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let insideChild = snapshot.value as? [String : Any]
            if let inside = insideChild {
                let totalRuns = inside[Constants.Keys.runs]
                returnTotalRuns = totalRuns as! Int
            }
            
            if returnTotalRuns != 0 {
                completion(returnTotalRuns)
            } else {
                return completion(0)
            }
        }
    }
    
    static func addToMiles(_ firUser: FIRUser, routeDistance: Double) {
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let insideChild = snapshot.value as? [String : Any?]
            if let inside = insideChild {
                var milesRun = inside[Constants.Keys.miles_run] as! Double
                milesRun = milesRun + routeDistance
                ref.updateChildValues([Constants.Keys.miles_run : milesRun])
            }
            
        }
    }
    
    static func addToRuns(_ firUser: FIRUser) {
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let insideChild = snapshot.value as? [String : Any?]
            if let inside = insideChild {
                var runs = inside[Constants.Keys.runs] as! Int
                runs = runs + 1
                ref.updateChildValues([Constants.Keys.runs : runs])
            }
        }
    }
    
    static func resetStatistics(_ firUser: FIRUser) {
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            ref.updateChildValues([Constants.Keys.miles_run : 0.0])
            ref.updateChildValues([Constants.Keys.runs : 0])
        }
    }
    
    static func getUsername(_ firUser: FIRUser, completion: @escaping (String?) -> Void) {
        var returnName = ""
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid).child(Constants.Keys.username)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? String {
                returnName = value
            }
            
            if returnName != "" {
                completion(returnName)
            } else {
                return completion("no name")
            }
        }
    }
}
