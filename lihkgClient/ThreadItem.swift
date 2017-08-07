//
//  thread.swift
//  lihkgClient
//
//  Created by lung on 24/7/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import ObjectMapper

class ThreadItem: Mappable {
    
    var threadId: String?
    var catId: String?
    var title: String?
    var userNickname: String?
    var userGender: String?
    var noOfReply: String?
    
    var createDate: Date?
    var lastReplyDate: Date?
    
    var likeCount: String?
    var dislikeCount: String?
    var totalPage: Int?
    
    var category: Category?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        threadId <- map["thread_id"]
        catId <- map["cat_id"]
        title <- map["title"]
        userNickname <- map["user_nickname"]
        userGender <- map["user_gender"]
        noOfReply <- map["no_of_reply"]
        
        createDate <- (map["create_time"], DateTransform())
        lastReplyDate <- (map["last_reply_time"], DateTransform())
        
        likeCount <- map["like_count"]
        dislikeCount <- map["dislike_count"]
        totalPage <- map["totalPage"]
        
        category <- map["category"]
    }
    
    func rankText() -> String {
        let rank: Int = Int(likeCount ?? "0")! - Int(dislikeCount ?? "0")!
        if rank >= 0 { // postive rank
            return "👍\(rank)"
        } else { //negative
            return "👎\(rank)"
        }
    }
 
    func noOfReplyText() -> String {
        return "📃\(noOfReply ?? "0")"
    }
    
    func userText() -> String {
        let dateString = String(describing: lastReplyDate!)
        return "\(userNickname ?? "") (\(dateString))"
    }
    
}
