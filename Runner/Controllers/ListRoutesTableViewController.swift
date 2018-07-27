//
//  ListRoutesTableViewController.swift
//  Runner
//
//  Created by Steven Mo on 7/25/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol DidTapCellProtocol {
    func didTapCell(nameOfRoute: String)
}

class ListRoutesTableViewController: UIViewController {

    var routes: [String]?
    var distances: [Double]?
    var delegate: DidTapCellProtocol?
    
    @IBOutlet weak var routesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.routesTableView.dataSource = self
        //self.table.delegate = self
        reload()

        // Do any additional setup after loading the view.
    }

    @IBAction func unwindToListRoutes(segue: UIStoryboardSegue) {
        reload()
    }
}

extension ListRoutesTableViewController {
    func reload() {
        RouteService.getAllRouteNames { (routes, routeDistances) in
            self.routes = routes
            self.distances = routeDistances
            self.routesTableView.reloadData()
        }
    }
}

extension ListRoutesTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.routes == nil {
            return 0
        } else {
            return self.routes!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! RouteTableViewCell
        
        if let routes = self.routes {
            let route = routes[indexPath.row]
            cell.routeNameLabel.text = route
            cell.routeDistanceLabel.text = "miles: \(distances![indexPath.row])"
            cell.routeLocationLabel.text = "testLocation"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            let cell = tableView.cellForRow(at: indexPath) as! RouteTableViewCell
            delegate?.didTapCell(nameOfRoute: cell.routeNameLabel.text!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "addRoute":
            print("addRoute button clicked")
//            let vc = segue.destination as! RouteCreationMapViewController
//            vc.delegate = self
            
        case "toRouteView":
            if let indexPath = self.routesTableView.indexPathForSelectedRow {
                let cell = self.routesTableView.cellForRow(at: indexPath) as! RouteTableViewCell

                let nav = segue.destination as! UINavigationController
                let vc = nav.topViewController as! RouteSelectedViewController
                vc.routeName = cell.routeNameLabel.text!
            }
            print("toRouteView")
            
        default:
            print("unexpected segue identifier")
        }
    }
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        reload()
    }
    
}