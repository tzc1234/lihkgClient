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

final class HtmlTagConverter {

    static let sharedInstance = HtmlTagConverter() // Shared Instance
    
    private let imgChar = "☐" // default image character, make sure the default image character is 1 length
    
    // color dictionary
    private let colorDic = [
        "color: red;": UIColor.red,
        "color: green;": UIColor.green,
        "color: blue;": UIColor.blue,
        "color: purple;": UIColor.purple,
        "color: violet;": UIColor(rgb: 0xEE82EE),
        "color: brown;": UIColor.brown,
        "color: pink;": UIColor(rgb: 0xFFC0CB),
        "color: orange;": UIColor.orange,
        "color: gold;": UIColor(rgb: 0xFFD700),
        "color: maroon;": UIColor(rgb: 0x800000),
        "color: teal;": UIColor(rgb: 0x008080),
        "color: navy;": UIColor(rgb: 0x000080),
        "color: limegreen;": UIColor(rgb: 0x32CD32)
    ]
    
    // size dictionary
    private let sizeDic = [
        "font-size: x-small;": UIFont.systemFont(ofSize: 12),
        "font-size: small;": UIFont.systemFont(ofSize: 14),
        "font-size: medium;": UIFont.systemFont(ofSize: 17),
        "font-size: large;": UIFont.systemFont(ofSize: 20),
        "font-size: x-large;": UIFont.systemFont(ofSize: 22),
        "font-size: xx-large;": UIFont.systemFont(ofSize: 24)
    ]
    
    private init() {}
    
//    private let attrsMsg = NSMutableAttributedString()
    
    // TODO handle expection
    func parseMsg(_ rawMsg: String?) -> (attributedMsg: NSMutableAttributedString, linkRangeDic: [String: [NSRange]]) {
        if rawMsg != nil {
            let html = "<lihkgClient>\(rawMsg!)</lihkgClient>"
            let divElements = try! SwiftSoup.parse(html).select("lihkgClient")
            let nodes = divElements.first()?.getChildNodes()
            
            let result = convertNodesToAttributedString(nodes: nodes!)
//            print("result linkRangeDic : \(result.linkRangeDic)")
//            print("result str : \(result.attributedMsg)")
//            print("urlImagLocs : \(result.urlImgLocs)")
            
            // insert url images asyn
            for (link, locations) in result.urlImgLocs {
                for location in locations {
                    Alamofire.request(link).responseImage { response in
                        if let urlImage = response.result.value {
                            
                            let attachment = NSTextAttachment()
                            attachment.image = urlImage
                            let attachmentString = NSAttributedString(attachment: attachment)
                            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
                            
                            let nsrange = NSRange(location: location, length: 1) // the length must be 1
                            result.attributedMsg.replaceCharacters(in: nsrange, with: mutableAttachmentString)
                        }
                    }
                }
            }
            
            return (result.attributedMsg, result.linkRangeDic)
        } else {
            return (NSMutableAttributedString(), [:])
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
                        _attrs[NSForegroundColorAttributeName] = colorDic[style] // TODO handle exception
                    } else if style.range(of: "font-size") != nil { // is size style
                        _attrs[NSFontAttributeName] = sizeDic[style] // TODO handle exception
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
                        attributedMsg.append(self.imgChar.toAttrsString())
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
