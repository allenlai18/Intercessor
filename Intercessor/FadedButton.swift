//
//  FadedButton.swift
//  Odio
//
//  Created by Xavier Sharp on 9/14/16.
//  Copyright © 2016 XQ Creative, LLC. All rights reserved.
//

import UIKit

class FadedButton: BorderButton {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                alpha = 1
                backgroundColor = UIColor.hex("#AC2A3A", alpha: 1.0)
            } else {
                alpha = 0.35
                backgroundColor = UIColor.clear
            }
        }
    }
}
