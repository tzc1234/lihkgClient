//
//  ThreadContentDataCell.swift
//  lihkgClient
//
//  Created by lung on 9/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class ThreadContentDataCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/
    
    func setThreadContentData(threadContentData: ThreadContentData) {
        messageLabel.text = threadContentData.msg
        titleLabel.attributedText = threadContentData.titleAttrsString()
        likeButton.setTitle(threadContentData.likeCountDislikeCountText(), for: .normal)
    }
    
}
