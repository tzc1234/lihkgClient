//
//  HtmlTagConverter.swift
//  lihkgClient
//
//  Created by lung on 15/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import SwiftSoup

final class HtmlTagConverter {

    static let sharedInstance = HtmlTagConverter() // Shared Instance
    
    // patterns
    private let colorPattern = "<span style=\"color: (\\w+);\">(.*)</span>"
    
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
    
    private init() {
        
    }
    
    func convertString(_ rawString: String) -> NSMutableAttributedString {
        
        return NSMutableAttributedString()
    }
    
    func parseMsg() {
        let rawMsg = "Add咗條女, 傾咗成個禮拜.....<img src=\"/assets/faces/normal/angry.gif\" class=\"hkgmoji\" /><br />\n最後露出狐狸尾巴<img src=\"/assets/faces/normal/frown.gif\" class=\"hkgmoji\" /><br />\n唉....."
        let html = "<div>\(rawMsg)</div>"
        
        //var substringDic = [String: [String: Any]]()
        
        do {
            //let doc: Document = try SwiftSoup.parseBodyFragment(html)
            let divElements = try SwiftSoup.parse(html).select("div")
            
//            let divText = try! divElement.text()
//            let attributedMsg = NSMutableAttributedString(string: divText)
//            print("string_without_tag = \(attributedMsg.string)")
            
//            for element in try! divElement.select("span") {
//                switch element.tagName() {
//                case "span":
//                    break
//                default:
//                    break
//                }
                
//                print("tagName -> \(element.tagName())")
//                let style = try! element.attr("style")
//                print("style -> \(style)")
//                print("element -> \(try! element.text())")
                
//            }
            
            //let eles = divElement.
            
            // let children = divElements.first()?.children()
//            let divTextNodes = divElements.first()?.textNodes()
//            for divTextNode in divTextNodes! {
//                print(divTextNode.text())
//            }
            
            
            // convertChildrenToAttributedString(children: children!)

            let nodes = divElements.first()?.getChildNodes()
            print("\n\(convertNodesToAttributedString(nodes: nodes!))")
            
            
            
        } catch Exception.Error( _, let message){
            print(message)
        } catch {
            print("error")
        }
        
    }
    
    private func convertNodesToAttributedString(nodes: [Node], level: Int = 0) -> String {
        let proLevel = level + 1
        // let attributedString = NSMutableAttributedString()
        var allText = ""
        
        for node: Node in nodes {
            print("nodeLevel\(proLevel) name -> \(node.nodeName())")
            
            switch node.nodeName() {
            case "#text":
                let text = node.getAttributes()?.get(key: "text")
                print("nodeLevel\(proLevel) text -> \(text ?? "")")
                
                allText += text!
            case "span":
                let style = node.getAttributes()?.get(key: "style")
                print("nodeLevel\(proLevel) style -> \(style ?? "")")
                
                let childNodes = node.getChildNodes()
                allText += convertNodesToAttributedString(nodes: childNodes, level: proLevel)
            case "img":
                let src = node.getAttributes()?.get(key: "src")
                print("nodeLevel\(proLevel) src -> \(src ?? "")")
                
                let klass = node.getAttributes()?.get(key: "class")
                print("nodeLevel\(proLevel) class -> \(klass ?? "")")
                
            case "a":
                let href = node.getAttributes()?.get(key: "href")
                print("nodeLevel\(proLevel) href -> \(href ?? "")")
            default:
                break
            }
        }
        
        return allText
    }
    
    
    
//    func matches(regex: String, text: String) -> [String] {
//        do {
//            
//            
//            
//        } catch let error {
//            print("invalid regex: \(error.localizedDescription)")
//            return []
//        }
//    }
    
}
