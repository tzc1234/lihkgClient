//
//  ThreadCell.swift
//  lihkgClient
//
//  Created by lung on 5/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class ThreadCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    */
 
    func setThreadItem(_ threadItem: ThreadItem) {
        titleLabel.text = threadItem.title
        userLabel.text = threadItem.userText()
        
        switch threadItem.userGender {
        case "M"?:
            userLabel.textColor = UIColor.cyan
        case "F"?:
            userLabel.textColor = UIColor.red
        default:
            userLabel.textColor = UIColor.white
        }
        
        postCountLabel.text = threadItem.noOfReplyText()
        rankLabel.text = threadItem.rankText()
    }
    
}
