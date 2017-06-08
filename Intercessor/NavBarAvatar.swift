//
//  ProfilePicButton.swift
//  odio
//
//  Created by Xavier Sharp on 8/11/16.
//  Copyright © 2016 XQ Creative, LLC. All rights reserved.
//

import UIKit

class NavBarAvatar: UIView {

    var view: UIView!
    
    @IBOutlet weak var containerView: BorderView!
    @IBOutlet weak var avatar: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        


        // Disable Touch
        self.view.isUserInteractionEnabled    = false
        self.isUserInteractionEnabled         = false
        self.avatar.isUserInteractionEnabled  = false
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NavBarAvatar", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
