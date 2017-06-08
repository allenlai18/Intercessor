//
//  BorderButton.swift
//  Odio
//
//  Created by Xavier Sharp on 12/15/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import Foundation

@IBDesignable

class BorderButton: UIButton {
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}

