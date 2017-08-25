//
//  ThreadContentDataCell.swift
//  lihkgClient
//
//  Created by lung on 9/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import UIKit

class ThreadContentDataCell: UITableViewCell {

    static let baseCellHeight: CGFloat = 8 + 10 + 10 + 45
    static let msgLabelWidth: CGFloat = 329
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // tappable link
    // reference: https://stackoverflow.com/a/28519273
    var layoutManagerCustom = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    var textStorage = NSTextStorage()
    
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
        
        let msgAttrsString = threadContentData.htmlTagConverter?.attributedMsg ?? NSMutableAttributedString()
        self.linkRangeDic = threadContentData.htmlTagConverter?.linkRanges // get back the link range collection
        
        msgLabel.attributedText = msgAttrsString
        
        // REVIEW: 329 was directly observed msgLabel's width after rendered. Any method to get the width b4 rendered?
        let expectedWidth: CGFloat = ThreadContentDataCell.msgLabelWidth
        let expectedHeight = msgLabel.sizeThatFits(CGSize(width: expectedWidth, height: 0)).height
        
        textContainer.size = CGSize(width: expectedWidth, height: expectedHeight)
        textStorage.append(msgAttrsString)
    }
    
    func tapMsgLabel(sender: UITapGestureRecognizer) {
        // update textStorage attributedString
        // TODO handle msgLabel.attributedText is nil
        textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length), with: msgLabel.attributedText!)
        
        let locationOfTouchInLabel = sender.location(in: sender.view)
        let labelSize = sender.view!.bounds.size
        let textBoundingBox = layoutManagerCustom.usedRect(for: textContainer)
        
        let x = (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x
        let y = (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        let textContainerOffset = CGPoint(x: x, y: y)
        let locationOfTouchInTextContainer =
            CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManagerCustom.characterIndex(for: locationOfTouchInTextContainer, in: textContainer,fractionOfDistanceBetweenInsertionPoints: nil)
        
        print("indexOfCharacter : \(indexOfCharacter)")
        
        // check the indexOfCharacter in which range of the link
        if self.linkRangeDic != nil {
            if self.linkRangeDic!.count > 0 {
//                print("linkRangeDic exist. \(self.linkRangeDic!)")
                
                var isExitLoop = false
                for (link, nsranges) in self.linkRangeDic! {
                    for nsrange in nsranges {
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
       
//        print("msgLabel height: \(msgLabel.frame.size.height)")
        
    } // end tapMsgLabel()
    
}
