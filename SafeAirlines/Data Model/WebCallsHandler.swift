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
var accessToken = "7cq8squxdq28qewx2xynzuk4"

func fetchData(fromURL url: String, withCompletionHandler completion: @escaping (Data?) -> Void) {
    let link = URL(string: url)
    Alamofire.request(link!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]).responseData(completionHandler: { response in
        switch response.result {
        case .success(let value):
            //let json = (value)
            
            //let json = try? JSONSerialization.jsonObject(with: <#T##Data#>, options: [])
            completion(value)
        case .failure(let error):
            //print(error)
            completion(nil)
        }
    })
    //.request(url!, method: .get, parameters: ["Authorization: Bearer b2d5h7n4chvpun2f4pu7jh36", "Accept: application/json"], encoding: JSONEncoding.default)
}

//responseJSON { response in
//    switch response.result {
//    case .success(let value):
//        //let json = (value)
//
//        //let json = try? JSONSerialization.jsonObject(with: <#T##Data#>, options: [])
//        completion(value)
//    case .failure(let error):
//        print(error)
//        completion(error)
//}

