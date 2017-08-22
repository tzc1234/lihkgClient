//
//  ThreadContentDataCell.swift
//  lihkgClient
//
//  Created by lung on 9/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class ThreadContentDataCell: UITableViewCell {

    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // tappable link
    // reference: https://stackoverflow.com/a/28519273
    var layoutManagerCustom = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    let textStorage = NSTextStorage()
    
    var linkRangeDic: [String: [NSRange]]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add tap gesture to msgLabel
        msgLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMsgLabel))
        msgLabel.addGestureRecognizer(tapGesture)
        
        // Configure layoutManager and textStorage
        layoutManagerCustom.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManagerCustom)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = msgLabel.lineBreakMode
        textContainer.maximumNumberOfLines = msgLabel.numberOfLines
    }
    
    func setThreadContentData(threadContentData: ThreadContentData) {
        titleLabel.attributedText = threadContentData.titleAttrsString()
        likeButton.setTitle(threadContentData.likeCountDislikeCountText(), for: .normal)
        
        let parsedMsgResult = threadContentData.getParsedMsgResult()
        let msgAttrsString = parsedMsgResult?.attributedMsg ?? NSMutableAttributedString()
        self.linkRangeDic = parsedMsgResult?.linkRangeDic // get back the link range collection
        
        msgLabel.attributedText = msgAttrsString
        
        let expectedWidth: CGFloat = 329 // REVIEW: 329 was directly observed msgLabel's width after rendered. Any method to get the width b4 rendered?
        let expectedHeight = msgLabel.sizeThatFits(CGSize(width: expectedWidth, height: 0)).height
        
        textContainer.size = CGSize(width: expectedWidth, height: expectedHeight)
        textStorage.append(msgAttrsString)
    }
    
    func tapMsgLabel(sender: UITapGestureRecognizer) {
        let locationOfTouchInLabel = sender.location(in: sender.view)
        let labelSize = sender.view!.bounds.size
        
        //print(labelSize)
        
        let textBoundingBox = layoutManagerCustom.usedRect(for: textContainer)
        //print(textBoundingBox)
        
        let x = (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x
        let y = (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        let textContainerOffset = CGPoint(x: x, y: y)
        let locationOfTouchInTextContainer =
            CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManagerCustom.characterIndex(for: locationOfTouchInTextContainer, in: textContainer,fractionOfDistanceBetweenInsertionPoints:nil)
        
        print("indexOfCharacter : \(indexOfCharacter)")
        
        // check the indexOfCharacter in which range of the link
        if self.linkRangeDic != nil {
            if self.linkRangeDic!.count > 0 {
//                print("linkRangeDic exist. \(self.linkRangeDic!)")
                
                var isExitLoop = false
                for (link, nsranges) in self.linkRangeDic! {
                    for nsrange in nsranges {
                        
//                        print("link: \(link), nsrange_loc: \(nsrange.location), nsrange_len: \(nsrange.length)")
                        
                        
                        if NSLocationInRange(indexOfCharacter, nsrange) {
                            print("current link : \(link)")
                            isExitLoop = true
                            
                            // TODO do url action
                            break
                        }
                        
                        if isExitLoop {
                            break
                        }
                    }
                }
            }
        }
       
        
    } // end tapMsgLabel()
    
}
