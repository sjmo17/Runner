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
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ListRoutesTableViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var routesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.routesTableView.dataSource = self
        self.routesTableView.addSubview(self.refreshControl)
        DispatchQueue.main.async {
            self.reload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
    
    @IBAction func unwindToListRoutes(segue: UIStoryboardSegue) {
        reload()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        reload()
        refreshControl.endRefreshing()
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
            } else {
                self.routesTableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.routeCell, for: indexPath) as! RouteTableViewCell
        
        if let routes = self.routes {
            var route = routes[indexPath.row]
            if let index = route.index(of: "_") {
                let sIndex = route.startIndex
                route.removeSubrange(sIndex...index)
            }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let firUser = Auth.auth().currentUser else { return }
            let cell = tableView.cellForRow(at: indexPath) as! RouteTableViewCell
            let routeName = cell.routeNameLabel.text
            UserService.getUsername(firUser) { (username) in
                let name = "\(username ?? "")_\(routeName ?? "")"
                RouteService.deleteRoute(firUser, routeName: name)
            }
            self.reload()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "toRouteView":
            if let indexPath = self.routesTableView.indexPathForSelectedRow {
                let cell = self.routesTableView.cellForRow(at: indexPath) as! RouteTableViewCell

                let nav = segue.destination as! UINavigationController
                let vc = nav.topViewController as! RouteSelectedViewController
                vc.routeName = cell.routeNameLabel.text!
            }
            
        default:
            print("unexpected segue identifier")
        }
    }
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        reload()
    }
    
}
