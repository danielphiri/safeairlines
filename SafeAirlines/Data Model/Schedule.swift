//
//  Schedule.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 6/5/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import Foundation
import MapKit

class Schedule {
//    var departureAirport = ""
//    var arrivalAirport = ""
    var departureDate = ""
    var originAirport: Airport!
    var destinationAirport: Airport!
    
    init() {
        
    }
    
//    func setDepartureAirportName(airport: String) {
//        self.departureAirport = airport
//    }
//    
//    func setArrivalAirport(airport: String) {
//        arrivalAirport = airport
//    }
    
    func setDepatureDate(date: String) {
        departureDate = date
    }
    
    func setDepartureAirport(airport: Airport) {
        self.originAirport = airport
    }
    
    func setDestinationAirport(airport: Airport) {
        self.destinationAirport = airport
    }
    
}
