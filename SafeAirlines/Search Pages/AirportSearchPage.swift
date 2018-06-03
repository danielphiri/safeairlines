//
//  AirportSearchPage.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 5/31/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//

import UIKit
import MapKit

class AirportSearchPage: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var locationManager = CLLocationManager()
    var tempFields = ["Oakland", "SFO", "Northen Land", "CA", "MLS", "MLK", "LAX", "LAS", "Athens", "Santorini"]
    var firstPartOfApi = "https://api.lufthansa.com/v1/references/airports/"
    var lastPartOfApi = "?limit=20&offset=0&LHoperated=0"
    var homeControllerInstance = HomePageController()
    var prototypeCell = "searchResultsCell"
    var cellNibName = "SearchResultsCell"
    
    // The field where the user types in the search
    lazy var searchField : UITextView = {
        let search = UITextView(frame: CGRect.init(x: 0, y: 87, width: view.frame.width, height: 35))
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
        return search
    }()
    
    // The table view to display result suggestions
    // as user types
    var resultsTableView : UITableView {
       let tableView = UITableView(frame: CGRect(x: 8, y: 125, width: 359, height: 600))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: cellNibName, bundle: .main), forCellReuseIdentifier: prototypeCell)
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if locationManager.location != nil {
            fethAirportData(withCode: nil, latitude: locationManager.location?.coordinate.latitude.description, andLongitude: locationManager.location?.coordinate.longitude.description)
        } else {
            fethAirportData(withCode: nil, latitude: nil, andLongitude: nil)
        }
        
        setUpViews()
    }
    
    func setUpViews() {
        view.backgroundColor = .white
        view.addSubview(searchField)
        view.addSubview(resultsTableView)
        searchField.becomeFirstResponder()
        if locationManager.location != nil {
            
        }
    }
    
    func fethAirportData(withCode code: String?, latitude: String?, andLongitude longitude: String?) {
        if code == nil && longitude != nil && latitude != nil {
            let url = "https://api.lufthansa.com/v1/references/airports/nearest/\(latitude!),\(longitude!)"
            processRequest(withURL: url)
        } else {
            if code == nil {
                let url = firstPartOfApi + lastPartOfApi
                processRequest(withURL: url)
            } else {
                let url = firstPartOfApi + code! + lastPartOfApi
                processRequest(withURL: url)
            }
        }
    }
    
    func processRequest(withURL url: String) {
        fetchData(fromURL: url, withCompletionHandler: {(results) -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: results!, options: [])
            } catch {
                print(error)
            }
            
            print(results)
            print(results)
        })
    }
    
    
}

extension AirportSearchPage {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: prototypeCell, for: indexPath) as! SearchResultsCell
        cell.title.text = tempFields[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
