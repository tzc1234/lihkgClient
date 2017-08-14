//
//  Extensions.swift
//  lihkgClient
//
//  Created by lung on 14/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation

extension String {
    func toAttrsString(attrs: [String: Any] = [:]) -> NSMutableAttributedString {
        let nsStr = self as NSString
        let range = NSMakeRange(0, nsStr.length)
        let attrsStr = NSMutableAttributedString(string: self)
        attrsStr.setAttributes(attrs, range: range)
        
        return attrsStr
    }
}

extension NSMutableAttributedString {
    static func + (lhs: NSMutableAttributedString, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
        let combination = NSMutableAttributedString()
        combination.append(lhs)
        combination.append(rhs)
        
        return combination
    }
}
