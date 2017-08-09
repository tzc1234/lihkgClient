//
//  User.swift
//  lihkgClient
//
//  Created by lung on 9/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var userId: String?
    var nickname: String?
    var level: String?
    var gender: String?
    var status: String?
    
    var creatDate: Date?
    var levelName: String?
    var isFollowing = false
    var isBlocked = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId <- map["user_id"]
        nickname <- map["nickname"]
        level <- map["level"]
        gender <- map["gender"]
        status <- map["status"]
        
        creatDate <- (map["create_time"], DateTransform())
        levelName <- map["level_name"]
        isFollowing <- map["is_following"]
        isBlocked <- map["is_blocked"]
    }
    
}
