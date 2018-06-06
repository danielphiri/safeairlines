//
//  Airport.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 6/4/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

class Airport {
    var code = ""
    var name = ""
    var location: CLLocationCoordinate2D!
    
    init() {
        
    }
    
    init(code: String) {
        self.code = code
        let url = "https://api.lufthansa.com/v1/references/airports/\(code)?limit=20&offset=0&LHoperated=0"
        fetchData(fromURL: url, withCompletionHandler: {(results) -> Void in
            //do {
            let json = JSON(results)
            let newJson = json["AirportResource"]
            let longitude = newJson["Airports"]["Airport"]["Position"]["Coordinate"]["Longitude"].description
            let latitude = newJson["Airports"]["Airport"]["Position"]["Coordinate"]["Latitude"].description
            self.setLocation(longitude: longitude, latitude: latitude)
            //}
        })
        
    }
    
    func setCode(code: String) {
        self.code = code
    }
    
    func setName(newName: String) {
        name = newName
    }
    
    func setLocation(longitude: String, latitude: String) {
        if let doubleLongitude = CLLocationDegrees(longitude), let doubleLatitude = CLLocationDegrees(latitude) {
            self.location = CLLocationCoordinate2D(latitude: doubleLatitude, longitude: doubleLongitude)
        }
    }
    
    
}
