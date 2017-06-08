//
//  LoadingIndicator.swift
//  Intercessor
//
//  Created by Allen Lai on 11/24/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation




open class ActivityIndicator {
    
    static func startActivityIndicator(vc: UIViewController, indicator: UIActivityIndicatorView) {
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        indicator.center = vc.view.center
        vc.view.addSubview(indicator)
        indicator.bringSubview(toFront: vc.view)
        indicator.startAnimating()
    }
    static func stopActivityIndicator(indicator: UIActivityIndicatorView) {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }


}
