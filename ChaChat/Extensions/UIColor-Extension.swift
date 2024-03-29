//
//  UIColor-Extension.swift
//  ChaChat
//
//  Created by sueko14 on 2020/08/15.
//  Copyright © 2020 sueko14. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue:  CGFloat) -> UIColor{
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
