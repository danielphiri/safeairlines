//
//  AirportSearchPage.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 5/31/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import SkeletonView
import MBProgressHUD

class AirportSearchPage: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, SkeletonTableViewDataSource {
    
    var isFirstAirport = false
    var isNearby = false
    let letters = NSCharacterSet.letters
    var locationManager = CLLocationManager()
    var tempFields = ["Oakland", "SFO", "Northen Land", "CA", "MLS", "MLK", "LAX", "LAS", "Athens", "Santorini"]
    var allAirports = [Airport]()
    var firstPartOfApi = "https://api.lufthansa.com/v1/references/airports/"
    var lastPartOfApi = "?limit=20&offset=0&LHoperated=0"
    var homeControllerInstance = HomePageController()
    var prototypeCell = "searchResultsCell"
    var cellNibName = "SearchResultsCell"
    var titleText = ""
    var navigationBarHeight: CGFloat = 87
    
    // The field where the user types in the search
    lazy var searchField : UITextView = {
        let search = UITextView(frame: CGRect.init(x: 0, y: navigationBarHeight, width: view.frame.width, height: 35))
        search.textColor = UIColor.init(red: 92/255, green: 94/255, blue: 102/255, alpha: 1)
        search.layer.cornerRadius = 10
        search.layer.borderColor = themeColor.withAlphaComponent(0.5).cgColor
        search.layer.borderWidth = 6
        search.layer.shadowColor = UIColor.init(red: 92/255, green: 94/255, blue: 102/255, alpha: 1).withAlphaComponent(0.5).cgColor
        search.layer.shadowOffset =  CGSize(width: 0, height: -3)
        search.layer.shadowOpacity = 0.5
        search.layer.shadowRadius = 6.0
        search.layer.masksToBounds = true
        search.font = UIFont.boldSystemFont(ofSize: 17)//(name: "Verdana", size: 16)
        search.textAlignment = .center
        search.delegate = self
        search.autocapitalizationType = .allCharacters
        search.returnKeyType = .search
        return search
    }()
    
    // The table view to display result suggestions
    // as user types
    var resultsTableView : UITableView {
       // 125
       let tableView = UITableView(frame: CGRect(x: 8, y: navigationBarHeight + 36, width: view.frame.width - 8, height: 600))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: cellNibName, bundle: .main), forCellReuseIdentifier: prototypeCell)
        tableView.isSkeletonable = true
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        if locationManager.location != nil && allAirports.count == 0 {
            fetchAirportData(withCode: nil, latitude: locationManager.location?.coordinate.latitude.description, andLongitude: locationManager.location?.coordinate.longitude.description)
        } else if allAirports.count == 0 {
            fetchAirportData(withCode: nil, latitude: nil, andLongitude: nil)
            titleText = "COULD NOT LOAD LOCATION. RECOMMENDED AIPORTS:"
        }
        showActivity()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchField.isEditable = true
        searchField.becomeFirstResponder()
    }
    
    // Sets up visibe views for class
    func setUpViews() {
        view.backgroundColor = .white
        view.addSubview(searchField)
        view.addSubview(resultsTableView)
        searchField.becomeFirstResponder()
    }
    
    // Determines what kind of api call to make depending on available data
    func fetchAirportData(withCode code: String?, latitude: String?, andLongitude longitude: String?) {
        showActivity()
        if code == nil && longitude != nil && latitude != nil && allAirports.count == 0 {
            //let url = "https://api-test.lufthansa.com/v1/references/airports/nearest/5.312034213,-0.21341234123"
            let url = "https://api.lufthansa.com/v1/references/airports/nearest/\(latitude!),\(longitude!)"
            titleText = "NEARBY AIPORTS:"
            processRequest(withURL: url, from: "Nearby")
        } else if (allAirports.count == 0)  {
            if code == nil {
                let url = firstPartOfApi + lastPartOfApi
                titleText = "COULD NOT LOAD LOCATION. RECOMMENDED AIPORTS:"
                processRequest(withURL: url, from: nil)
            } else {
                let url = firstPartOfApi + code! + lastPartOfApi
                titleText = "AIPORTS MATCHING YOUR SEARCH:"
                processRequest(withURL: url, from: "Search")
            }
        }
    }
    
    // Handles all alerts within class
    func showSystemAlert(title: String, message: String, type: String?) {
        hideActivity()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Okay", style: .default, handler: {(s) -> Void in
            self.hideActivity()
        })
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    let progress = MBProgressHUD()
    
    // Shows an activity indicator when data is loading
    func showActivity() {
        
        MBProgressHUD.showAdded(to: resultsTableView, animated: true)
        view.addSubview(progress)
        progress.show(animated: true)
    }
    
    // Hides the activity indicator when data has finished loading
    func hideActivity() {
        MBProgressHUD.hide(for: resultsTableView, animated: true)
        progress.hide(animated: true)
    }
    
    // Makes call to model and handles returned data
    func processRequest(withURL url: String, from: String?) {
        allAirports.removeAll()
        fetchData(fromURL: url, withCompletionHandler: {(results) -> Void in
            let json = JSON(results)
            if json["AirportResource"] != JSON.null {
                self.extractAirports(fromJSON: json["AirportResource"], from: from)
            } else if json["NearestAirportResource"] != JSON.null {
                self.extractAirports(fromJSON: json["NearestAirportResource"], from: from)
            } else {
                self.showSystemAlert(title: "Oops, No airport data matching your search was found 😬", message: "Please try your search again. (PRO TIP: Make sure your airport code has only 3 characters!). Thank us later 😉", type: "Alert")
            }
        })
    }
    
    // Called when user input text changes
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.last == "\n" {
            textView.text.removeLast()
            checkCode(code: textView.text)
        } else if textView.text.count == 3 {
            textView.resignFirstResponder()
            checkCode(code: textView.text)
            MBProgressHUD.showAdded(to: resultsTableView, animated: true)
        }
    }
    
    // Called when user clicks "Search button"
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchField.text.last == "\n" {
            searchField.text.removeLast()
        } else if searchField.text.count != 3 {
            self.showSystemAlert(title: "Ooh, wait ✋🏿", message: "Your code needs to be EXACTLY 3 characters long. Please reset your search and try again.", type: "Error")
        } else {
            showActivity()
            checkCode(code: searchField.text)
        }
    }
    
    //Checks if code is valid
    func checkCode(code: String) {
        let range = code.rangeOfCharacter(from: letters)
        if let _ = range {
            allAirports.removeAll()
            self.fetchAirportData(withCode: code, latitude: nil, andLongitude: nil)
        }
    }
    
    func extractAirports(fromJSON json: JSON, from: String?) {
        if from == "Search" {
            let longitude = json["Airports"]["Airport"]["Position"]["Coordinate"]["Longitude"].description
            let latitude = json["Airports"]["Airport"]["Position"]["Coordinate"]["Latitude"].description
            let airportCode = json["Airports"]["Airport"]["AirportCode"].description
            let newAirport = Airport()
            newAirport.setCode(code: airportCode)
            newAirport.setLocation(longitude: longitude, latitude: latitude)
            allAirports.append(newAirport)
        } else {
            for data in json["Airports"]["Airport"] {
                let currData = data.1
                print(currData)
                let longitude = currData["Position"]["Coordinate"]["Longitude"].description
                let latitude = currData["Position"]["Coordinate"]["Latitude"].description
                let airportCode = currData["AirportCode"].description
                let newAirport = Airport()
                newAirport.setCode(code: airportCode)
                newAirport.setLocation(longitude: longitude, latitude: latitude)
                allAirports.append(newAirport)
            }
        }
        self.reloadList()
    }
    
    func reloadList() {
        showActivity()
        DispatchQueue.main.async {
            self.hideActivity()
            self.resultsTableView.reloadData()
            self.viewDidLoad()
        }
    }
}

extension AirportSearchPage {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAirports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: prototypeCell, for: indexPath) as! SearchResultsCell
        cell.title.text = allAirports[indexPath.row].code
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = allAirports[indexPath.row].code
        if isFirstAirport {
            homeControllerInstance.originAirport.text = "FROM: \(text)"
            homeControllerInstance.originAirport.textColor = .black
            homeControllerInstance.originAirport.font = UIFont.boldSystemFont(ofSize: 16)
            navigationController?.popViewController(animated: true)
        } else {
            homeControllerInstance.destinationAirport.text = "TO: \(text)"
            homeControllerInstance.destinationAirport.textColor = .black
            homeControllerInstance.destinationAirport.font = UIFont.boldSystemFont(ofSize: 16)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdenfierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return prototypeCell
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


