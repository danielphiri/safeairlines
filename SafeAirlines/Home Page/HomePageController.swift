//
//  HomePageController.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 5/31/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import UIKit
import MapKit
//import MapKitGoogleStyler

class HomePageController: UIViewController, UITextViewDelegate,  CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager!
    
    @IBOutlet var backGroundView: UIView!
    
    @IBOutlet weak var airportsDisplay: MKMapView!
    
    @IBOutlet weak var originAirport: UITextView!
    
    @IBOutlet weak var destinationAirport: UITextView!
    
    @IBOutlet weak var actionButtonOutlet: UIButton!
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originAirport.delegate = self
        destinationAirport.delegate = self
        airportsDisplay.delegate = self
        
        customizeUI()
        setUpMap()
    }
    
    // Make the UI look GREAT
    func customizeUI() {
//        self.navigationController?.navigationBar.titleTextAttributes = [
//            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
//        ]
//        navigationController?.navigationBar.tintColor = .white
        actionButtonOutlet.isHidden = true
        actionButtonOutlet.layer.cornerRadius = 10
        actionButtonOutlet.layer.masksToBounds = true
        actionButtonOutlet.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        actionButtonOutlet.layer.shadowOffset =  CGSize(width: 0, height: -3)
        actionButtonOutlet.layer.shadowOpacity = 0.5
        actionButtonOutlet.layer.shadowRadius = 6.0
        actionButtonOutlet.layer.borderColor = themeColor.cgColor
        actionButtonOutlet.layer.borderWidth = 1
        
        originAirport.layer.cornerRadius = 10
        originAirport.layer.borderColor = themeColor.cgColor
        originAirport.layer.borderWidth = 1
        originAirport.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        originAirport.layer.shadowOffset =  CGSize(width: 0, height: -3)
        originAirport.layer.shadowOpacity = 0.5
        originAirport.layer.shadowRadius = 6.0
        originAirport.layer.masksToBounds = true
        
        destinationAirport.layer.cornerRadius = 10
        destinationAirport.layer.borderColor = themeColor.cgColor
        destinationAirport.layer.borderWidth = 1
        destinationAirport.layer.shadowColor = UIColor.red.withAlphaComponent(0.5).cgColor
        destinationAirport.layer.shadowOffset =  CGSize(width: 0, height: -3)
        destinationAirport.layer.shadowOpacity = 0.5
        destinationAirport.layer.shadowRadius = 6.0
        destinationAirport.layer.masksToBounds = true
        
        //backGroundView.layer.cornerRadius = 5
        backGroundView.backgroundColor = themeColor.withAlphaComponent(0.3)
        backGroundView.layer.shadowColor = themeColor.withAlphaComponent(0.5).cgColor
        backGroundView.layer.shadowOffset =  CGSize(width: 0, height: -3)
        backGroundView.layer.shadowOpacity = 0.5
        backGroundView.layer.shadowRadius = 6.0
        backGroundView.layer.masksToBounds = true
        
        airportsDisplay.mapType = .hybrid
    }
    
    // Set up the map on the Main Page
    func setUpMap() {
        if CLLocationManager.locationServicesEnabled() {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined {
                let alertController = UIAlertController(title: "Howdy there 😀", message: "Please grant us access to your location while using the app. We will only use this information to find nearby airports. You will not be able to use the app without this permission.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Not Now", style: .cancel, handler: {
                    [unowned self] (action) -> Void in
                    let alert = UIAlertController(title: "Okay, please come back later when you change your mind 😉", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .destructive, handler: {(result) -> Void in
                        exit(0)
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: {(results) -> Void in
                        self.setUpMap()
                    })
                    alert.addAction(action)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                })
                let allowAction = UIAlertAction(title: "Allow", style: .default, handler: {
                    [unowned self] (action) -> Void in
                    self.locationManager.requestWhenInUseAuthorization()
                })
                alertController.addAction(defaultAction)
                alertController.addAction(allowAction)
                present(alertController, animated: true, completion: nil)
            } else if status == CLAuthorizationStatus.authorizedWhenInUse {
                self.updateLocation()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let nextPage = AirportSearchPage()
        //present(nextPage, animated: true, completion: nil)
        nextPage.homeControllerInstance = self
        navigationController?.pushViewController(nextPage, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined {
                let alertController = UIAlertController(title: "Location Permission:", message: "SafeAirlines would like to access your location. We will use this information to show houses that are close to you and to show your location in relative to houses.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Not Now", style: .cancel, handler: {
                    [unowned self] (action) -> Void in
                    let alert = UIAlertController(title: "Okay, please come back later when you change your mind 😉", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .destructive, handler: {(result) -> Void in
                        exit(0)
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alert.addAction(action)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                })
                let allowAction = UIAlertAction(title: "Allow", style: .default, handler: {
                    [unowned self] (action) -> Void in
                    self.locationManager.requestWhenInUseAuthorization()
                })
                alertController.addAction(defaultAction)
                alertController.addAction(allowAction)
                present(alertController, animated: true, completion: nil)
            } else if status == CLAuthorizationStatus.authorizedWhenInUse {
                self.updateLocation()
            }
        }
    }
    
    func updateLocation() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if locationManager.location != nil {
            centerMapOnLocation(location: (locationManager.location)!)
        }
        locationManager.startUpdatingLocation()
        self.airportsDisplay.showsUserLocation = true
        //self.greekMap.showsBuildings = true
        //self.greekMap.showsPointsOfInterest = true
    }
    
    let regionRadius: CLLocationDistance = 100
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        airportsDisplay.setRegion(coordinateRegion, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        navigationItem.backBarButtonItem = backItem
//    }

}
