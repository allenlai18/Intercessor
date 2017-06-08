//
//  Image.swift
//  Intercessor
//
//  Created by Allen Lai on 12/3/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation


class Image: NSObject {
    
    class func square(_ image: UIImage, size: CGFloat) -> UIImage {
        var cropped: UIImage?
        if image.size.height > image.size.width {
            let ypos: CGFloat = (image.size.height - image.size.width) / 2
            cropped = self.crop(image, x: 0, y: ypos, width: image.size.width, height: image.size.width)
        }
        else {
            let xpos: CGFloat = (image.size.width - image.size.height) / 2
            cropped = self.crop(image, x: xpos, y: 0, width: image.size.height, height: image.size.height)
        }
        return self.resize(cropped!, width: size, height: size, scale: 1)
    }
    
    class func resize(_ image: UIImage, width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let rect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: rect)
        let resized = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resized
    }
    

    
    class func crop(_ image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {
        let rect = CGRect(x: x, y: y, width: width, height: height)
        let imageRef = image.cgImage!.cropping(to: rect)!
        let cropped = UIImage(cgImage: imageRef)
//        CGImageRelease(imageRef)
        return cropped
    }
}

