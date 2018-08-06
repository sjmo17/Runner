//
//  Constants.swift
//  Runner
//
//  Created by Steven Mo on 8/1/18.
//  Copyright © 2018 Steven Mo. All rights reserved.
//

import Foundation

struct Constants {
    struct UserDefaults {
        static let currentUser = "currentUser"
    }
    
    struct Keys {
        static let users = "users"
        static let username = "username"
        static let miles_run = "miles_run"
        static let runs = "runs"
        static let routes = "routes"
        static let latitudes = "latitudes"
        static let longitudes = "longitudes"
        static let distance = "distance"
        static let location = "location"
    }
    
    struct Storyboards {
        static let Main = "Main"
        static let Login = "Login"
    }
    
    struct Segues {
        static let unwindToListRoutes = "unwindToListRoutes"
        static let toCreateUsername = "toCreateUsername"
    }
    
    struct Cells {
        static let routeCell = "routeCell"
    }
}
