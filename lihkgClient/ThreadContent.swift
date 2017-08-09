//
//  ThreadContent.swift
//  lihkgClient
//
//  Created by lung on 9/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import ObjectMapper

class ThreadContent: Mappable {
    
    var threadId: String?
    var catId: String?
    var title: String?
    var userId: String?
    var userNickname: String?
    var userGender: String?
    
    var noOfReply: String?
    var likeCount: String?
    var dislikeCount: String?
    
    var createDate: Date?
    var lastReplyDate: Date?
    
    var lastReplyUserId: String?
    var totalPage: Int?
    var page: Int?
    
    var category: Category?
    var isBookmarked = false
    var user: User?
    
    var itemData: [ThreadContentData]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        threadId <- map["thread_id"]
        catId <- map["cat_id"]
        title <- map["title"]
        userId <- map["user_id"]
        userNickname <- map["user_nickname"]
        userGender <- map["user_gender"]
        
        noOfReply <- map["no_of_reply"]
        likeCount <- map["like_count"]
        dislikeCount <- map["dislike_count"]
        
        createDate <- (map["create_time"], DateTransform())
        lastReplyDate <- (map["last_reply_time"], DateTransform())

        lastReplyUserId <- map["last_replay_user_id"]
        totalPage <- map["total_page"]
        page <- map["page"]
        
        category <- map["categpry"]
        isBookmarked <- map["is_bookmarked"]
        user <- map["user"]
        
        itemData <- map["item_data"]
    }
}
