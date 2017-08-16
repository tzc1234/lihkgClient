//
//  Extensions.swift
//  lihkgClient
//
//  Created by lung on 14/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import UIKit

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

// reference: https://stackoverflow.com/a/24263296
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
