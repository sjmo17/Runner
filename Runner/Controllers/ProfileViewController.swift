//
//  ProfileViewController.swift
//  Runner
//
//  Created by Steven Mo on 7/30/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    @IBOutlet weak var totalRunsLabel: UILabel!
    
    //var milesrun = 0.0
    //var runs = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let firUser = Auth.auth().currentUser else { return }
        let ref = Database.database().reference().child("users").child(firUser.uid).child("username")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? String {
                self.profileUsernameLabel.text = value
            }
        }
        
        let name = Auth.auth().currentUser?.displayName
        profileNameLabel.text = name
        
        UserService.getMilesRun(firUser) { (miles) in
            //.milesrun = miles!
            self.totalMilesLabel.text = String(miles!)
        }
        UserService.getTotalRuns(firUser) { (runs) in
            //self.runs = runs!
            self.totalRunsLabel.text = String(runs!)
        }
        
    }
    
    
}
