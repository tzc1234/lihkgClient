//
//  LihkgHtmlStyles.swift
//  lihkgClient
//
//  Created by lung on 24/8/2017.
//  Copyright © 2017年 lung. All rights reserved.
//

import Foundation
import UIKit

struct LihkgHtmlStyles {
    
    // color dictionary
    static let colorDictionary = [
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
    static let sizeDictionary = [
        "font-size: x-small;": UIFont.systemFont(ofSize: 12),
        "font-size: small;": UIFont.systemFont(ofSize: 14),
        "font-size: medium;": UIFont.systemFont(ofSize: 17),
        "font-size: large;": UIFont.systemFont(ofSize: 20),
        "font-size: x-large;": UIFont.systemFont(ofSize: 22),
        "font-size: xx-large;": UIFont.systemFont(ofSize: 24)
    ]
}
