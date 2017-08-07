//
//  postTitle.swift
//  lihkgClient
//
//  Created by lung on 23/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import ObjectMapper

class Threads: Mappable {
    
    var category: Category?
    var isPagination: Bool = false
    var items: [ThreadItem]?
    
//    func getProps() -> [String] {
//        return Mirror(reflecting: self).children.flatMap { $0.label }
//    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        category <- map["category"]
        isPagination <- map["is_pagination"]
        items <- map["items"]
    }
    
}
