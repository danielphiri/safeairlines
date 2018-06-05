//
//  Airport.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 6/4/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import Foundation
import MapKit

class Airport {
    var code = ""
    var name = ""
    var location: CLLocationCoordinate2D!
    
    init() {
        
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
