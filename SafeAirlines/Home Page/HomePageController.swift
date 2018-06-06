//
//  HomePageController.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 5/31/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import MBProgressHUD

class HomePageController: UIViewController, UITextViewDelegate,  CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let regionRadius: CLLocationDistance = 100
    var existingAirports = [String: Airport]()
    var locationManager: CLLocationManager!
    var originAirportPrompt = "Which airport are you coming from? 🤔"
    var destinationPrompt = "Which airport are you going to? 🤔"
    var prototypeCell = "searchResultsCell"
    var cellNibName = "SearchResultsCell"
    var allSchedules = [Schedule]()
    var titleText = "MATCHING SCHEDULES:"
    @IBOutlet weak var schedulesTableView: UITableView!
    
    @IBOutlet var backGroundView: UIView!
    
    @IBOutlet weak var airportsDisplay: MKMapView!
    
    @IBOutlet weak var originAirport: UITextView!
    
    @IBOutlet weak var destinationAirport: UITextView!
    
    @IBOutlet weak var actionButtonOutlet: UIButton!
    
    // The action that's called when the go button has been
    // pressed
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        allSchedules.removeAll()
        MBProgressHUD.showAdded(to: view, animated: true)
        let from = subStringToEnd(startingAtIndex: 5, from: originAirport.text)
        let to = subStringToEnd(startingAtIndex: 3, from: destinationAirport.text)
        let url = "https://api.lufthansa.com/v1/operations/schedules/\(from)/\(to)/\(getTodaysDate())?directFlights=0"
        fetchData(fromURL: url, withCompletionHandler: {(results) -> Void in
            let json = JSON(results)
            let schedules = json["ScheduleResource"]["Schedule"]
            for schedule in schedules {
                var newSchedule = Schedule()
                var flight = schedule.1["Flight"][0]
                if flight == JSON.null {
                    flight = schedule.1["Flight"]
                }
                let arrival = flight["Arrival"]["AirportCode"].string
                let departure = flight["Departure"]["AirportCode"].string
                let departureDate = flight["Arrival"]["ScheduledTimeLocal"]["DateTime"].string
                newSchedule.setDepatureDate(date: departureDate!)
                newSchedule = self.setDeparture(departure: departure!, schedule: newSchedule)
                newSchedule = self.setArrival(arrival: arrival!, schedule: newSchedule)
                if self.unique(schedule: newSchedule) {
                    self.allSchedules.append(newSchedule)
                }
            }
            self.refreshSchedules()
        })
    }
    
    // Make sure schedule doesn't already exist
    // before passing it in
    func unique(schedule: Schedule) -> Bool {
        for schedu in allSchedules {
            if schedu.departureDate == schedule.departureDate && schedule.originAirport.code == schedu.originAirport.code && schedu.destinationAirport.code == schedule.destinationAirport.code {
                return false
            }
        }
        return true
    }
    
    // Set the departure time in given schedule
    func setDeparture(departure: String, schedule: Schedule) -> Schedule {
        if !self.existingAirports.keys.contains(departure) {
            let newAirport = Airport(code: departure)
            schedule.setDepartureAirport(airport: newAirport)
            self.existingAirports[departure] = newAirport
        } else if self.existingAirports.keys.contains(departure) {
            schedule.setDepartureAirport(airport: self.existingAirports[departure]!)
        }
        return schedule
    }
    
    // Set the arrival time in given schedule
    func setArrival(arrival: String, schedule: Schedule) -> Schedule {
        if !self.existingAirports.keys.contains(arrival) {
            let newAirport = Airport(code: arrival)
            schedule.setDestinationAirport(airport: newAirport)
            self.existingAirports[arrival] = newAirport
        } else if self.existingAirports.keys.contains(arrival) {
            schedule.setDestinationAirport(airport: self.existingAirports[arrival]!)
        }
        return schedule
    }
    
    
    // Refresh flight schedules after all
    // data has been returned
    func refreshSchedules() {
        DispatchQueue.main.async {
            self.schedulesTableView.reloadData()
            self.schedulesTableView.isHidden = false
            self.viewWillAppear(true)
        }
    }
    
    // Get a substring of the given string, removing all characters from the
    // index 0 to the passed int, inclusive
    func subStringToEnd(startingAtIndex index: Int, from: String) -> String {
        var count = 0
        var newString = from
        while count <= index {
            newString.removeFirst()
            count += 1
        }
        return newString
    }
    
    // Get today's date in the YYY-MM-DD format
    func getTodaysDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "YYYY-MM-dd"
        let resultString = inputFormatter.string(from: Date())
        return resultString
    }
    
    @IBOutlet weak var clearButtonOutlet: UIButton!
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        if originAirport.textColor != UIColor.black && destinationAirport.textColor != UIColor.black {
            //ALERT
        } else if originAirport.textColor == UIColor.black && destinationAirport.textColor == UIColor.black {
            originAirport.text = originAirportPrompt
            originAirport.textColor = .lightGray
            destinationAirport.text = destinationPrompt
            destinationAirport.textColor = .lightGray
            actionButtonOutlet.isHidden = true
            clearButtonOutlet.isHidden = true
        } else {
            if originAirport.text != originAirportPrompt  {
                originAirport.text = originAirportPrompt
                originAirport.textColor = .lightGray
                clearButtonOutlet.isHidden = true
            } else {
                destinationAirport.text = destinationPrompt
                destinationAirport.textColor = .lightGray
                clearButtonOutlet.isHidden = true
            }
        }
        schedulesTableView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originAirport.delegate = self
        destinationAirport.delegate = self
        airportsDisplay.delegate = self
        schedulesTableView.delegate = self
        schedulesTableView.dataSource = self
        schedulesTableView.register(UINib(nibName: cellNibName, bundle: .main), forCellReuseIdentifier: prototypeCell)
        customizeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MBProgressHUD.hide(for: view, animated: true)
        setUpMap()
        if allSchedules.count == 0 {
            schedulesTableView.isHidden = true
        }
        if originAirport.textColor == UIColor.black && destinationAirport.textColor == UIColor.black {
            actionButtonOutlet.isHidden = false
        } else if originAirport.textColor == UIColor.black || destinationAirport.textColor == UIColor.black {
            clearButtonOutlet.isHidden = false
        }
    }
    
    // Customize this class' views
    func customizeUI() {

        // Customize and hide go button
        actionButtonOutlet.isHidden = true
        actionButtonOutlet.layer.cornerRadius = 10
        actionButtonOutlet.layer.masksToBounds = true
        actionButtonOutlet.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        actionButtonOutlet.layer.shadowOffset =  CGSize(width: 0, height: -3)
        actionButtonOutlet.layer.shadowOpacity = 0.5
        actionButtonOutlet.layer.shadowRadius = 6.0
        actionButtonOutlet.layer.borderColor = themeColor.cgColor
        actionButtonOutlet.layer.borderWidth = 1
        
        // Customize and hide clear button
        clearButtonOutlet.isHidden = true
        clearButtonOutlet.layer.cornerRadius = 10
        clearButtonOutlet.layer.masksToBounds = true
        clearButtonOutlet.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        clearButtonOutlet.layer.shadowOffset =  CGSize(width: 0, height: -3)
        clearButtonOutlet.layer.shadowOpacity = 0.5
        clearButtonOutlet.layer.shadowRadius = 6.0
        clearButtonOutlet.layer.borderColor = UIColor.white.cgColor
        clearButtonOutlet.layer.borderWidth = 1
        
        // Customize departure textview
        originAirport.layer.cornerRadius = 10
        originAirport.layer.borderColor = themeColor.cgColor
        originAirport.layer.borderWidth = 1
        originAirport.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        originAirport.layer.shadowOffset =  CGSize(width: 0, height: -3)
        originAirport.layer.shadowOpacity = 0.5
        originAirport.layer.shadowRadius = 6.0
        originAirport.layer.masksToBounds = true
        
        // Customize destination textview
        destinationAirport.layer.cornerRadius = 10
        destinationAirport.layer.borderColor = themeColor.cgColor
        destinationAirport.layer.borderWidth = 1
        destinationAirport.layer.shadowColor = UIColor.red.withAlphaComponent(0.5).cgColor
        destinationAirport.layer.shadowOffset =  CGSize(width: 0, height: -3)
        destinationAirport.layer.shadowOpacity = 0.5
        destinationAirport.layer.shadowRadius = 6.0
        destinationAirport.layer.masksToBounds = true
        
        // Customize bacjground
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
    
    // Called when the user begins typing
    func textViewDidBeginEditing(_ textView: UITextView) {
        let nextPage = AirportSearchPage()
        nextPage.homeControllerInstance = self
        if textView == originAirport {
           nextPage.isFirstAirport = true
        } else {
            nextPage.isFirstAirport = false
        }
        navigationController?.pushViewController(nextPage, animated: true)
    }
    
    // Called when the location authorization status changes on device
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined {
                let alertController = UIAlertController(title: "Location Permission:", message: "SafeAirlines would like to access your location. We will only use this information to show nearby airports.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Not Now", style: .cancel, handler: {
                    [unowned self] (action) -> Void in
                    let alert = UIAlertController(title: "Okay, just so you know, the app is more fun to use when this authorization has been enabled 😉", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(action)
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
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        airportsDisplay.setRegion(coordinateRegion, animated: true)
    }
}

extension HomePageController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: prototypeCell, for: indexPath) as! SearchResultsCell
        let from = allSchedules[indexPath.row].originAirport.code
        let to = allSchedules[indexPath.row].destinationAirport.code
        let time = allSchedules[indexPath.row].departureDate
        cell.title.text = "From: \(from) To: \(to) On: \(time)"
        MBProgressHUD.hide(for: view, animated: true)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)
        let nextPage = RoutesView()
        nextPage.origin = allSchedules[indexPath.row].originAirport
        nextPage.destination = allSchedules[indexPath.row].destinationAirport
        navigationController?.pushViewController(nextPage, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 28))
        label.textAlignment = .center
        label.backgroundColor = .groupTableViewBackground
        view.backgroundColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .gray
        label.text = titleText
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        return view
    }
}
