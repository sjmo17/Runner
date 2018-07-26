//
//  RouteTableViewCell.swift
//  Runner
//
//  Created by Steven Mo on 7/25/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var routeLocationLabel: UILabel!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
