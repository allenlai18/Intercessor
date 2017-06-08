//
//  PaddedTextField.swift
//  Intercessor
//
//  Created by Allen Lai on 11/10/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation

class PaddedTextField: UITextField {
    
    //    override init(frame: CGRect) {
    //        super.init(frame: frame)
    //
    //        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
    //        clearButton.setImage(UIImage(named: "clearButton")!, for: UIControlState())
    //
    //        self.rightView = clearButton
    //        clearButton.addTarget(self, action: #selector(PaddedTextField.clearClicked(_:)), for: UIControlEvents.touchUpInside)
    //
    //        self.clearButtonMode = UITextFieldViewMode.never
    //        self.rightViewMode = UITextFieldViewMode.always
    //    }
    //
    func clearClicked(_ sender:UIButton)
    {
        self.text = ""
    }
    
    func roundTextField() {
        
        self.layer.cornerRadius = 25
        self.layer.borderColor = UIColor.hex("AC2A3A", alpha: 1).cgColor
        self.layer.borderWidth = 1.0

    }
    func setLeftImageToEmail() {
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = UIImageView(image: UIImage(named: "EmailIcon"))
    }
    func setLeftImageToPassword() {
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = UIImageView(image: UIImage(named: "PasswordIcon"))
    }
    
    func setLeftImageToFullName() {
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = UIImageView(image: UIImage(named: "FullNameIcon"))
    }
    func setLeftImageToUsername() {
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = UIImageView(image: UIImage(named: "UsernameIcon"))
    }
    
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += 22
        return textRect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        textRect.origin.x += 10
        return textRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.editingRect(forBounds: bounds)
        textRect.origin.x += 10
        return textRect
    }
    
}


