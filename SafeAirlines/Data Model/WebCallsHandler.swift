//
//  WebCallsHandler.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 5/31/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//
import Alamofire

import Foundation

//Lufthansa's Acess Token. If no data is being returned, get yours
// at developers.lufthansa.com
var accessToken = "bv8cg5knkxuadh4puk6x9vfa"

func fetchData(fromURL url: String, withCompletionHandler completion: @escaping (Data?) -> Void) {
    let link = URL(string: url)
    Alamofire.request(link!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]).responseData(completionHandler: { response in
        switch response.result {
        case .success(let value):
            completion(value)
        case .failure:
            completion(nil)
        }
    })
}
