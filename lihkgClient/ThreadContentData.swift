//
//  ThreadContentData.swift
//  lihkgClient
//
//  Created by lung on 9/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import ObjectMapper
import DateToolsSwift

class ThreadContentData: Mappable {
    
    var postId: String?
    var threadId: String?
    var userNickname: String?
    var userGender: String?
    var likeCount: String?
    var dislikeCount: String?
    var voteScore: String?
    
    var replyDate: Date?
    var msg: String?
    
    var user: User?
    var msgNum: Int?
    var score: Int?
    var page: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        postId <- map["post_id"]
        threadId <- map["thread_id"]
        userNickname <- map["user_nickname"]
        userGender <- map["user_gender"]
        likeCount <- map["like_count"]
        dislikeCount <- map["dislike_count"]
        voteScore <- map["vote_score"]
        
        replyDate <- (map["reply_time"], DateTransform())
        msg <- map["msg"]
        
        user <- map["user"]
        msgNum <- map["msg_num"]
        score <- map["score"]
        page <- map["page"]
    }
    
    func titleText() -> String {
        return "#\(msgNum ?? 0) \(userNickname ?? "")・\(replyDateText())"
    }
    
    func replyDateText() -> String {
        return replyDate?.shortTimeAgoSinceNow ?? ""
    }
    
    func likeCountDislikeCountText() -> String {
        return "👍\(likeCount ?? "0")　👎\(dislikeCount ?? "0")"
    }
    
}
