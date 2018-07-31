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
        let userAttrs = ["username" : username,
                         "miles_run" : 0,
                         "runs" : 0] as [String : Any]
        let ref = Database.database().reference().child("users").child(firUser.uid)
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
        var returnMilesRun = -1.0
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let insideChild = snapshot.value as? [String : Any]
            if let inside = insideChild {
                let milesRun = inside["miles_run"]
                returnMilesRun = milesRun as! Double
            }
            
            if returnMilesRun != -1 {
                completion (returnMilesRun)
            } else {
                return completion(nil)
            }
        }
    }
}
