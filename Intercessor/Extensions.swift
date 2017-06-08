//
//  Extensions.swift
//  Intercessor
//
//  Created by Allen Lai on 9/14/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation


extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        if urlString == "" {
            self.image = UIImage(named: "defaultProfileImage")
            return
        }
        self.image = nil
        // check cache for image first
        if let cachedImage = Helper.imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        // otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            // download hit an error so lets return out
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    Helper.imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                } else {
                    self.image = UIImage(named: "defaultProfileImage")
                }
            })
            
        }).resume()
    }
    
    
}


extension UITextField {
    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension Date {
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
}




internal extension UIColor {
    
    class func hex (_ hexStr : NSString, alpha : CGFloat) -> UIColor {
        
        let realHexStr = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: realHexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string", terminator: "")
            return UIColor.white
        }
    }
}



extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func fadeIn(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.alpha = 1
        })
    }
    
    func addBottomBorder(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
        border.borderWidth = width
        self.layer.addSublayer(border)
    }
    
    func addGradient(_ alpha: CGFloat) {
        self.addGradient(alpha, end: 1.0)
    }
    
    func addGradient(endLocation end: CGFloat) {
        self.addGradient(1.0, end: end)
    }
    
    func addGradient(_ alpha: CGFloat, end: CGFloat) {
        let colorTop    = UIColor(red: 0/255.0,
                                  green: 0/255.0,
                                  blue: 0/255.0,
                                  alpha: 0).cgColor
        let colorBottom = UIColor(red: 0/255.0,
                                  green: 0/255.0,
                                  blue: 0/255.0,
                                  alpha: alpha).cgColor
        
        let gradientLayer       = CAGradientLayer()
        gradientLayer.frame     = self.bounds
        gradientLayer.colors    = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, NSNumber(value: Float(end))]
        
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        //        self.layer.addSublayer(gradientLayer)
    }
    
    
    
}
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    var isValidUsername: Bool {
        if !(4...16 ~= self.characters.count) {
            return false
        }
        
        // check that name doesn't contain whitespace or newline characters
        let range = self.rangeOfCharacter(from: .whitespacesAndNewlines)
        if let range = range , range.lowerBound != range.upperBound {
            return false
        }
        
        return true
    }
    
    var isValidPassword: Bool {
        if !(8...100 ~= self.characters.count) {
            return false
        }
        
        let range = self.rangeOfCharacter(from: .whitespacesAndNewlines)
        if let range = range , range.lowerBound != range.upperBound {
            return false
        }
        
        return true
    }
    
    var isValidHashTag: Bool {
        if self.contains(".") || self.contains("$") || self.contains("#")
            || self.contains("[") || self.contains("]") {
            return false
        }
        return true
    }
    
    var isValidMention: Bool {
        if self.contains(".") || self.contains("$") || self.contains("#")
            || self.contains("[") || self.contains("]") {
            return false
        }
        return true
    }

}
