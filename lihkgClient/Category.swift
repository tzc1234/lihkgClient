//
//  Category.swift
//  lihkgClient
//
//  Created by lung on 24/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import ObjectMapper

class Category: Mappable {
    
    var catId: String?
    var name: String?
    var postable: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        catId <- map["cat_id"]
        name <- map["name"]
        postable <- map["postable"]
    }

    
}
