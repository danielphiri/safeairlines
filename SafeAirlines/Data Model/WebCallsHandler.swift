//
//  WebCallsHandler.swift
//  SafeAirlines
//
//  Created by Daniel Phiri on 5/31/18.
//  Copyright © 2018 Daniel Phiri. All rights reserved.
//
import Alamofire

import Foundation

func fetchData(fromURL url: String, withCompletionHandler completion: @escaping (Data?) -> Void) {
    let url = URL(string: url)
    Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default).responseData(completionHandler: { response in
        switch response.result {
        case .success(let value):
            //let json = (value)
            
            //let json = try? JSONSerialization.jsonObject(with: <#T##Data#>, options: [])
            completion(value)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    })
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

