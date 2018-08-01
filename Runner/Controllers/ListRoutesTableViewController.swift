//
//  ListRoutesTableViewController.swift
//  Runner
//
//  Created by Steven Mo on 7/25/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol DidTapCellProtocol {
    func didTapCell(nameOfRoute: String)
}

class ListRoutesTableViewController: UIViewController {

    var routes: [String]?
    var distances = [Double]()
    var delegate: DidTapCellProtocol?
    var addresses = [String]()
    
    @IBOutlet weak var routesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.routesTableView.dataSource = self
        //self.table.delegate = self
        reload()

        // background image for routesTableView
        let backgroundImage = UIImage(named: "nightskysmall.png")
        let imageView = UIImageView(image: backgroundImage)
        self.routesTableView.backgroundView = imageView
        routesTableView.tableFooterView = UIView(frame: CGRect.zero)
        //imageView.contentMode = .scaleAspectFit
    }

    @IBAction func unwindToListRoutes(segue: UIStoryboardSegue) {
        reload()
    }
}

extension ListRoutesTableViewController {
    func reload() {
        distances.removeAll()
        addresses.removeAll()
        guard let firUser = Auth.auth().currentUser else { return }
        RouteService.getUserRoutes(firUser) { (routes) in
            self.routes = routes
            if routes != nil {
                for route in routes! {
                    
                    RouteService.getRouteDistance(routeName: route, completion: { (distance) in
                        self.distances.append(distance!)
                        RouteService.getRouteLocation(routeName: route, completion: { (location) in
                            self.addresses.append(location!)
                            if self.distances.count == self.routes?.count && self.addresses.count == self.routes?.count {
                                self.routesTableView.reloadData()
                            }
                        })
                    })
                }
            }
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
            var distance = distances[indexPath.row]
            distance = distance - distance.truncatingRemainder(dividingBy: 0.001)
            cell.routeDistanceLabel.text = "miles: \(distance)"
            cell.routeLocationLabel.text = "\(addresses[indexPath.row])"
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
