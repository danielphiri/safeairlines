//
//  RoutesView.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 6/6/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class RoutesView: UIViewController {
    
    var origin = Airport()
    var destination = Airport()
    let locationManager = CLLocationManager()
    var mapView = GMSMapView()

    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: origin.location.latitude, longitude: origin.location.longitude, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        drawLines()
    }
    
    func drawLines() {
        let path = GMSMutablePath()
        path.add(origin.location)
        path.add(destination.location)
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
        polyline.strokeWidth = 10
        polyline.strokeColor = themeColor
        polyline.geodesic = true
        
        let originMarker = GMSMarker()
        originMarker.position = origin.location
        originMarker.title = origin.code
        originMarker.snippet = origin.code
        originMarker.map = mapView
        
        let destinationMarker = GMSMarker()
        destinationMarker.position = destination.location
        destinationMarker.title = destination.code
        destinationMarker.snippet = destination.code
        destinationMarker.map = mapView
    }

}
