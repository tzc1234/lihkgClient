//
//  HtmlTagConverter.swift
//  lihkgClient
//
//  Created by lung on 15/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftGifOrigin
import Alamofire
import AlamofireImage

class MyTextAttachment : NSTextAttachment {
    
//    override public var image: UIImage? {
//        didSet {
//            print("image size : \(image!.size)")
//        }
//    }
    
    var loc: Int?
    var isGif = false
    
//    override func image(forBounds imageBounds: CGRect,
//                        textContainer: NSTextContainer?,
//                        characterIndex charIndex: Int) -> UIImage?{
//        
//        print("imageBounds: \(imageBounds)")
//
//        if let attributedString = textContainer?.layoutManager?.textStorage {
//            print("string : \(attributedString.string)")
//            let nsrange = NSRange(location: customLoc!, length: 1)
//            textContainer?.layoutManager?.invalidateDisplay(forCharacterRange: nsrange)
//        }
//        
//        
//        return super.image(forBounds: imageBounds, textContainer: textContainer, characterIndex: charIndex)
//    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
//        print("lineFrag : \(lineFrag)")
        
       return super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
    }
    
}

class HtmlTagConverter {

    private let imgPlaceholder = "☐" // default image character, make sure the default image character is 1 length
    private var rawMsg: String
    
    var cellIndexPath: IndexPath?
    
    var attributedMsg: NSMutableAttributedString?
    var linkRanges: [String: [NSRange]]?
    var urlImgLocs: [String: [Int]]?
    
    init(rawMsg: String) {
        self.rawMsg = rawMsg
        parseRawMsg()
    }
    
    // TODO handle expection case!
    func parseRawMsg() {
        let html = "<lihkgClient>\(self.rawMsg)</lihkgClient>"
        let lihkgClientElements = try! SwiftSoup.parse(html).select("lihkgClient")
        let nodes = lihkgClientElements.first()?.getChildNodes()
        
        let result = convertNodesToAttributedString(nodes: nodes!)
        self.attributedMsg = result.attributedMsg
        self.linkRanges = result.linkRangeDic
        self.urlImgLocs = result.urlImgLocs
        
        asyncLoadImages()
    }
    
    private let prototypeLabel = UILabel()
    func getExpectedCellHeight() -> CGFloat {
        self.prototypeLabel.numberOfLines = 0
        self.prototypeLabel.attributedText = self.attributedMsg
        
        let expectedWidth: CGFloat = ThreadContentDataCell.msgLabelWidth
        let expectedHeight = self.prototypeLabel.sizeThatFits(CGSize(width: expectedWidth, height: CGFloat.greatestFiniteMagnitude)).height
        
        return expectedHeight + ThreadContentDataCell.baseCellHeight
    }
    
    func asyncLoadImages() {
        if self.urlImgLocs != nil {
            for (link, locations) in self.urlImgLocs! {
                for location in locations {
                    Alamofire.request(link).responseImage { [weak self] response in
                        if let urlImage = response.result.value {
                            let attachment = MyTextAttachment()
                            
                            // scale down the image size
                            let imgWidth = urlImage.size.width
                            if imgWidth > ThreadContentDataCell.msgLabelWidth {
                                let ratio = imgWidth / ThreadContentDataCell.msgLabelWidth
                                let imgHeight = urlImage.size.height / ratio
                                attachment.bounds = CGRect(x: 0, y: 0, width: ThreadContentDataCell.msgLabelWidth, height: imgHeight)
                            }
                            
                            attachment.image = urlImage
                            attachment.loc = location
                            if link.lowercased().range(of: ".gif") != nil {
                                attachment.isGif = true
                            }
                            
                            let attachmentString = NSAttributedString(attachment: attachment)
                            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
                            
                            let nsrange = NSRange(location: location, length: 1) // the length must be 1
                            self?.attributedMsg?.replaceCharacters(in: nsrange, with: mutableAttachmentString)
                            
                            print("load image success.")
                            
                            // sent notifications for reloading correspondence table cell
                            NotificationCenter.default.post(name: Notification.Name("reloadThreadContentDataCell"), object: self?.cellIndexPath)
                        }
                    }
                }
            }
        }
    }
    
    private func convertNodesToAttributedString(
        nodes: [Node],
        level: Int = 0,
        attrs: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 17)
        ],
        linkRangeDic: [String: [NSRange]] = [:],
        rootAttributedMsgLength: Int = 0,
        urlImgLocs: [String: [Int]] = [:])
        ->
        (attributedMsg: NSMutableAttributedString, linkRangeDic: [String: [NSRange]], rootAttributedMsgLength: Int, urlImgLocs: [String: [Int]])
    {
        var _linkRangeDic = linkRangeDic // for saving the link nsrange in attributedMsg
        let _rootAttributedMsgLength = rootAttributedMsgLength
        var _urlImgLocs = urlImgLocs
        
        let proLevel = level + 1
        let attributedMsg = NSMutableAttributedString()
        
        for node: Node in nodes {
//            print("nodeLevel\(proLevel)_tag_name -> \(node.nodeName())")
            
            switch node.nodeName() {
            case "#text":
                if let text = node.getAttributes()?.get(key: "text") {
//                    print("nodeLevel\(proLevel) text -> \(text)")
                    
                    let attributedStr = text.toAttrsString(attrs: attrs)
                    attributedMsg.append(attributedStr)
                }
            case "span":
                if let style = node.getAttributes()?.get(key: "style") {
//                    print("nodeLevel\(proLevel) style -> \(style)")
                    
                    var _attrs = attrs
                    if style.range(of: "color") != nil { // is color style
                        _attrs[NSForegroundColorAttributeName] = LihkgHtmlStyles.colorDictionary[style] // TODO handle exception
                    } else if style.range(of: "font-size") != nil { // is size style
                        _attrs[NSFontAttributeName] = LihkgHtmlStyles.sizeDictionary[style] // TODO handle exception
                    }
                    
                    let currentAttributedMsgLength = (attributedMsg.string as NSString).length
                    let newRootAttributedMsgLength = currentAttributedMsgLength + rootAttributedMsgLength
                    let result = convertNodesToAttributedString(
                        nodes: node.getChildNodes(),
                        level: proLevel,
                        attrs: _attrs,
                        linkRangeDic: _linkRangeDic,
                        rootAttributedMsgLength: newRootAttributedMsgLength,
                        urlImgLocs: _urlImgLocs)
                    
                    // update variables after recursion returned
                    attributedMsg.append(result.attributedMsg)
                    _linkRangeDic = result.linkRangeDic
                    _urlImgLocs = result.urlImgLocs
                }
            case "img":
                let klass = node.getAttributes()?.get(key: "class")
                if let src = node.getAttributes()?.get(key: "src") {
                    var link = src.trimmingCharacters(in: .whitespaces) // trim whitespaces
                    
                    if klass == "hkgmoji" { // hkgmoji, load local icons.
                        link.remove(at: link.startIndex) // remove leading "/"
                        let filePath = link.components(separatedBy: ".") // remove file extension
                        
                        if filePath.first != nil {
                            var img: UIImage?
                            if filePath.first!.range(of: "lomoji") != nil { // lomoji png
                                img = UIImage(named: filePath.first!)
                            } else { // gif icons
                                img = UIImage.gif(name: filePath.first!)
                            }
                            
                            let attachment = NSTextAttachment()
                            attachment.image = img
                            let attachmentString = NSAttributedString(attachment: attachment)
                            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
                            
                            attributedMsg.append(mutableAttachmentString)
                        }
                    } else { // image from url
                        // calculate and save the image loc
                        if _urlImgLocs[link] == nil {
                            _urlImgLocs[link] = []
                        }
                        
                        let currentAttributedMsgLength = (attributedMsg.string as NSString).length
                        let linkLocation = currentAttributedMsgLength + rootAttributedMsgLength
                        _urlImgLocs[link]?.append(linkLocation)
                        
                        // add default img character to attributedMsg first
                        attributedMsg.append(self.imgPlaceholder.toAttrsString())
                    }
                    
                }
            case "a":
                if let href = node.getAttributes()?.get(key: "href") {
                    let trimmedHref = href.trimmingCharacters(in: .whitespaces) // trim whitespaces
                    let attributedStr = trimmedHref.toAttrsString(attrs:
                        [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                            NSForegroundColorAttributeName: UIColor.green
                        ])
                    
                    // calculate nsrange
                    let currentLevelAttributedMsgLength = (attributedMsg.string as NSString).length
                    let herfLength = (trimmedHref as NSString).length
                    let linkRange = NSMakeRange(currentLevelAttributedMsgLength + rootAttributedMsgLength, herfLength)
                    
                    // save the link nsrange
                    if _linkRangeDic[trimmedHref] == nil {
                        _linkRangeDic[trimmedHref] = []
                    }
                    _linkRangeDic[trimmedHref]?.append(linkRange)
                    
                    attributedMsg.append(attributedStr)
                    
                    // print("_linkRangeDic: \(_linkRangeDic)")
                    // print("nodeLevel\(proLevel) href -> \(trimmedHref)")
                }
            case "div":
                let currentAttributedMsgLength = (attributedMsg.string as NSString).length
                let newRootAttributedMsgLength = currentAttributedMsgLength + rootAttributedMsgLength
                let result = convertNodesToAttributedString(
                    nodes: node.getChildNodes(),
                    level: proLevel,
                    attrs: attrs,
                    linkRangeDic: _linkRangeDic,
                    rootAttributedMsgLength: newRootAttributedMsgLength,
                    urlImgLocs: _urlImgLocs)
                
                // update variables after recursion returned
                attributedMsg.append(result.attributedMsg)
                _linkRangeDic = result.linkRangeDic
                _urlImgLocs = result.urlImgLocs
            case "strong":
                // TODO bold
//                var _attrs = attrs
//                _attrs["NSFontAttributeName"] = UIFont.boldSystemFont(ofSize: 17)
                
                let currentAttributedMsgLength = (attributedMsg.string as NSString).length
                let newRootAttributedMsgLength = currentAttributedMsgLength + rootAttributedMsgLength
                let result = convertNodesToAttributedString(
                    nodes: node.getChildNodes(),
                    level: proLevel,
                    attrs: attrs,
                    linkRangeDic: _linkRangeDic,
                    rootAttributedMsgLength: newRootAttributedMsgLength,
                    urlImgLocs: _urlImgLocs)
                
                // update variables after recursion returned
                attributedMsg.append(result.attributedMsg)
                _linkRangeDic = result.linkRangeDic
                _urlImgLocs = result.urlImgLocs
            default: // default append text
                if let text = node.getAttributes()?.get(key: "text"), !text.isEmpty {
//                    print("nodeLevel\(proLevel) default text -> \(text)")
                    let attributedStr = text.toAttrsString(attrs: attrs)
                    attributedMsg.append(attributedStr)
                }
            }
        }
        
        return (attributedMsg, _linkRangeDic, _rootAttributedMsgLength, _urlImgLocs)
    }
    
}
