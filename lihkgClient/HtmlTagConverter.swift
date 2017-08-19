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

final class HtmlTagConverter {

    static let sharedInstance = HtmlTagConverter() // Shared Instance
    
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
    
    // TODO handle expection
    func parseMsg(_ rawMsg: String?) -> (attributedMsg: NSMutableAttributedString, linkRangeDic: [String: [NSRange]]) {
        if rawMsg != nil {
            let html = "<div>\(rawMsg!)</div>"
            let divElements = try! SwiftSoup.parse(html).select("div")
            let nodes = divElements.first()?.getChildNodes()
            
            let result = convertNodesToAttributedString(nodes: nodes!)
//            print("linkRangeDic : \(result.linkRangeDic)")
            
            
//            print("result str : \(result.attributedMsg)")
            
            return result
        } else {
            return (NSMutableAttributedString(), [:])
        }
    }
    
//    func parseMsg2() {
//        let rawMsg = ""
//        let html = "\(rawMsg)"
//        
//        do {
//            
//            let rootElements = try SwiftSoup.parse(html).select("ul")
//
//            let nodes = rootElements.first()?.getChildNodes()
//            print("\n\(convertNodesToAttributedString(nodes: nodes!))")
//            
//            
//            
//        } catch Exception.Error( _, let message){
//            print(message)
//        } catch {
//            print("error")
//        }
//        
//    }
    
    private func convertNodesToAttributedString(nodes: [Node], level: Int = 0, attrs: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 17)
        ], linkRangeDic: [String: [NSRange]] = [:]) -> (attributedMsg: NSMutableAttributedString, linkRangeDic: [String: [NSRange]])
    {
        var _linkRangeDic = linkRangeDic // for saving the link nsrange in attributedMsg
        let proLevel = level + 1
        let attributedMsg = NSMutableAttributedString()
        
        for node: Node in nodes {
//            print("nodeLevel\(proLevel) name -> \(node.nodeName())")
            
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
                    
                    var newAttrs = attrs
                    if style.range(of:"color") != nil { // is color style
                        newAttrs[NSForegroundColorAttributeName] = colorDic[style] // TODO handle exception
                    } else if style.range(of:"font-size") != nil { // is size style
                        newAttrs[NSFontAttributeName] = sizeDic[style] // TODO handle exception
                    }
                    
                    let childNodes = node.getChildNodes()
//                    print("call self.")
                    let attributedStr = convertNodesToAttributedString(
                        nodes: childNodes,
                        level: proLevel,
                        attrs: newAttrs,
                        linkRangeDic: _linkRangeDic).attributedMsg
                    attributedMsg.append(attributedStr)
                }
            case "img":
                let klass = node.getAttributes()?.get(key: "class")
//                print("nodeLevel\(proLevel) class -> \(klass ?? "")")
                if klass == "hkgmoji" {
                    if var src = node.getAttributes()?.get(key: "src") {
                        src.remove(at: src.startIndex)
                        let filePath = src.components(separatedBy: ".")
                        // print("nodeLevel\(proLevel) src -> \(filePath.first ?? "")")
                        
                        if filePath.first != nil {
                            //let img = UIImage(named: "faces/lomoji/02")
                            let img = UIImage.gif(name: filePath.first!)
                            let attachment = NSTextAttachment()
                            attachment.image = img
                            let attachmentString = NSAttributedString(attachment: attachment)
                            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
                            attributedMsg.append(mutableAttachmentString)
                        }
                    }
                }
            case "a":
                if let href = node.getAttributes()?.get(key: "href") {
                    let trimmedHref = href.trimmingCharacters(in: .whitespaces) // trim spaces in href
                    let attributedStr = trimmedHref.toAttrsString(attrs:
                        [
                            // NSLinkAttributeName: URL(string: trimmedHref) ?? "",
                            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                            NSForegroundColorAttributeName: UIColor.green,
                            // NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
                        ])
                    
                    // calculate nsrange
                    let attributedMsgLength = (attributedMsg.string as NSString).length
                    let herfLength = (trimmedHref as NSString).length
                    let linkRange = NSMakeRange(attributedMsgLength, herfLength)
                    
                    // save the link nsrange
                    if _linkRangeDic[trimmedHref] == nil {
                        _linkRangeDic[trimmedHref] = []
                    }
                    _linkRangeDic[trimmedHref]?.append(linkRange)
                    
                    // append attributedStr
                    attributedMsg.append(attributedStr)
                    
//                    print("nodeLevel\(proLevel) href -> \(trimmedHref)")
                }
            default:
                if let text = node.getAttributes()?.get(key: "text") { // default append text
//                    print("nodeLevel\(proLevel) default text -> \(text)")
                    let attributedStr = text.toAttrsString(attrs: attrs)
                    attributedMsg.append(attributedStr)
                }
            }
        }
        
        return (attributedMsg, _linkRangeDic)
    }
    
}
