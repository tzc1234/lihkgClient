//
//  ApiConnect.swift
//  lihkgClient
//
//  Created by lung on 22/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class ApiConnect {
    
    // contants:
    static let baseUrl = "https://lihkg.com/api_v1_1/"
    static let baseHeaders: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    // functions:
    static func sentRequest(_ lastUrl: String, method: HTTPMethod, parameters: Parameters?, completion: @escaping (Dictionary<String, Any>?, Error?) -> Void) {
        let wholeUrl = baseUrl + lastUrl

        Alamofire.request(wholeUrl, method: method, parameters: parameters, headers: baseHeaders).validate().responseJSON { response in
            switch response.result {
            case .success(let json):
                print("Api call success")
                completion(json as? Dictionary, nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
        
        
//        Alamofire.request(wholeUrl, method: method, parameters: parameters, headers: baseHeaders)
//            .validate()
//            .responseObject { (response: DataResponse<PostTitle>) in
//        
//                switch response.result {
//                case .success(let json):
//                    print("Api call success")
//                    
//                    let postTitle = response.result.value
//                    
//                    completion(postTitle, nil)
//                case .failure(let error):
//                    print(error)
//                    completion(nil, error)
//                }
//   
//        }
        
    } // call()
    
    static func getThreads(parameters: Parameters? = nil, completion: @escaping (Dictionary<String, Any>?, Error?) -> Void) {
        sentRequest("thread/latest", method: .get, parameters: parameters, completion: completion)
    }
}
