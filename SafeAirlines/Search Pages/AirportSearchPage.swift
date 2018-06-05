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
         //87
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
       let tableView = UITableView(frame: CGRect(x: 8, y: navigationBarHeight + 36, width: 359, height: 600))
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
            titleText = "LOCATION DISABLED. RECOMMENDED AIPORTS:"
        }
        
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchField.isEditable = true
        searchField.becomeFirstResponder()
    }
    
    func setUpViews() {
        view.backgroundColor = .white
        view.addSubview(searchField)
        view.addSubview(resultsTableView)
        searchField.becomeFirstResponder()
        if locationManager.location != nil {
            
        }
    }
    
    func fetchAirportData(withCode code: String?, latitude: String?, andLongitude longitude: String?) {
        if code == nil && longitude != nil && latitude != nil && allAirports.count == 0 {
            //let url = "https://api-test.lufthansa.com/v1/references/airports/nearest/5.312034213,-0.21341234123"
            let url = "https://VXjkwwSGh4.lufthansa.com/v1/references/airports/nearest/\(latitude!),\(longitude!)/application/json"
            titleText = "LOCATION DISABLED. RECOMMENDED AIPORTS:"
            processRequest(withURL: url)
        } else if (allAirports.count == 0)  {
            if code == nil {
                let url = firstPartOfApi + lastPartOfApi
                titleText = "AIRPORTS MATCHING YOUR SEARCH:"
                processRequest(withURL: url)
            } else {
                let url = firstPartOfApi + code! + lastPartOfApi
                titleText = "AIRPORTS MATCHING YOUR SEARCH:"
                processRequest(withURL: url)
            }
        }
    }
    
    func processRequest(withURL url: String) {
        allAirports.removeAll()
        fetchData(fromURL: url, withCompletionHandler: {(results) -> Void in
            do {
                
                //let json = try JSONSerialization.data(withJSONObject: results!, options: [])//.jsonObject(with: results!, options: [])
                let json = JSON(results)
                if json["AirportResource"] != JSON.null {
                    self.extractAirports(fromJSON: json["AirportResource"] )
                }
               
                //let j = JS
            } catch {
                //ERROR
                //print(error)
            }
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 3 {
            textView.isEditable = false
            textView.resignFirstResponder()
            checkCode(code: textView.text)
        }
            //.text = textView.text.capitalized
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchField.text.count != 3 {
            //ERROR
        } else {
            checkCode(code: searchField.text)
        }
    }
    
    //Checks if code is valid
    func checkCode(code: String) {
        let range = code.rangeOfCharacter(from: letters)
        // range will be nil if no letters is found
        if let test = range {
            //println("letters found")
            allAirports.removeAll()
            self.fetchAirportData(withCode: test.description, latitude: nil, andLongitude: nil)
        }
        else {
            //ERROR
            //println("letters not found")
        }

    }
    
    func extractAirports(fromJSON json: JSON) {
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
        self.reloadList()
    }
    
    func reloadList() {
        DispatchQueue.main.async {
//            let path = IndexPath(row: 0, section: 0)
//            self.resultsTableView.insertRows(at: [path], with: .top)
            
            self.resultsTableView.reloadData()
            self.viewDidLoad()
            print("kay")
        }
    }
}

extension AirportSearchPage {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if allAirports.count == 0 {
//            //SDStateTableView.setState(.withImage(image: "empty_cart",
////                                                 title: "Nearest Aiports Loading",
////                                                 message: "Your nearest airports will finish loading in a few seconds"))
//        }
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isNearby {
            return "Nearby Airports:"
        } else {
            return "Matching Airports:"
        }
    }
}


