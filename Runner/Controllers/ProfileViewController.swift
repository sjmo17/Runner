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
            guard let miles = miles else { return }
            var milesToDisplay = miles
            milesToDisplay = miles - miles.truncatingRemainder(dividingBy: 0.001)
            self.totalMilesLabel.text = String(milesToDisplay)
        }
        UserService.getTotalRuns(firUser) { (runs) in
            //self.runs = runs!
            guard let runs = runs else { return }
            self.totalRunsLabel.text = String(runs)
        }
        
        let lineView = UIView(frame: CGRect(x: 20, y: 205, width: 375, height: 1.0))
//        let margins = view.layoutMarginsGuide
//        lineView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10).isActive = true
//        lineView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 10).isActive = true
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(lineView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let firUser = Auth.auth().currentUser else { return }
        
        UserService.getMilesRun(firUser) { (miles) in
            //.milesrun = miles!
            guard let miles = miles else { return }
            var milesToDisplay = miles
            milesToDisplay = miles - miles.truncatingRemainder(dividingBy: 0.001)
            self.totalMilesLabel.text = String(milesToDisplay)
        }
        UserService.getTotalRuns(firUser) { (runs) in
            //self.runs = runs!
            guard let runs = runs else { return }
            self.totalRunsLabel.text = String(runs)
        }
    }
}
