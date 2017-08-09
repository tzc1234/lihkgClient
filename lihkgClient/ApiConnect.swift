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

// Singleton
// Reference: https://stackoverflow.com/a/39860897
final class ApiConnect {
    
    static let sharedInstance = ApiConnect() // Shared Instance
    
    // instane variables
    private let baseUrl = "https://lihkg.com/api_v1_1/"
    private let sessionManger: SessionManager // create session manger
    private var headers = Alamofire.SessionManager.defaultHTTPHeaders // default headers
    
    // Can't init, is singleton
    private init() {
        // add custom header
        // self.headers["Accept"] = "application/json"
        
        // create a custom session configuration
        let configuration = URLSessionConfiguration.default
        
        // add the headers
        // configuration.httpAdditionalHeaders = headers
        
        // create a session manager with the configuration
        self.sessionManger = Alamofire.SessionManager(configuration: configuration)
    }
    
    // functions:
    
    private func sentRequest(_ lastUrl: String, method: HTTPMethod, parameters: Parameters?) -> DataRequest {
        let wholeUrl = baseUrl + lastUrl
        
        return sessionManger.request(wholeUrl, method: method, parameters: parameters).validate()
    }
    
    func getThreads(parameters: Parameters? = nil) -> DataRequest {
        return sentRequest("thread/latest", method: .get, parameters: parameters)
    }
    
    func getThreadContent(threadId: String, page: String, parameters: Parameters? = nil) -> DataRequest {
        return sentRequest("thread/\(threadId)/page/\(page)", method: .get, parameters: parameters)
    }
    
}
