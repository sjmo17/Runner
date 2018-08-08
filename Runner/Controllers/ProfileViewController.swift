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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let firUser = Auth.auth().currentUser else { return }
        let ref = Database.database().reference().child(Constants.Keys.users).child(firUser.uid).child(Constants.Keys.username)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? String {
                self.profileUsernameLabel.text = value
            }
        }
        
        let name = Auth.auth().currentUser?.displayName
        profileNameLabel.text = name
        
        UserService.getMilesRun(firUser) { (miles) in
            guard let miles = miles else { return }
            var milesToDisplay = miles
            milesToDisplay = miles - miles.truncatingRemainder(dividingBy: 0.001)
            self.totalMilesLabel.text = String(milesToDisplay)
        }
        UserService.getTotalRuns(firUser) { (runs) in
            guard let runs = runs else { return }
            self.totalRunsLabel.text = String(runs)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let firUser = Auth.auth().currentUser else { return }
        
        UserService.getMilesRun(firUser) { (miles) in
            guard let miles = miles else { return }
            var milesToDisplay = miles
            milesToDisplay = miles - miles.truncatingRemainder(dividingBy: 0.001)
            self.totalMilesLabel.text = String(milesToDisplay)
        }
        UserService.getTotalRuns(firUser) { (runs) in
            guard let runs = runs else { return }
            self.totalRunsLabel.text = String(runs)
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        guard let firUser = Auth.auth().currentUser else { return }
        
        totalMilesLabel.text = "0.0"
        totalRunsLabel.text = "0"
        UserService.resetStatistics(firUser)
    }
    
}
