//
//  SignUpVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/10/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var passwordTextField: PaddedTextField!
    
    @IBOutlet weak var nextButton: FadedButton!
    
    let notification = ALNotification()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.roundTextField()
        emailTextField.setLeftImageToEmail()
        passwordTextField.roundTextField()
        passwordTextField.setLeftImageToPassword()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.becomeFirstResponder()
        
        nextButton.isEnabled = false
        
    }

    @IBAction func nextButtonTapped(_ sender: Any) {

        if !emailTextField.text!.isValidEmail  {
            notification.error("Error", message: "invalid email")
            return
        }
        if !passwordTextField.text!.isValidPassword {
            notification.error("Error", message: "invalid password")
            return
        }
        // TODO: check if the email is already taken yet if not then segue
        
        if nextButton.isEnabled {
            let authSB = UIStoryboard(name: "Auth", bundle: nil)
            let yourProfileVC = authSB.instantiateViewController(withIdentifier: "YourProfile") as! YourProfileVC
            yourProfileVC.email = emailTextField.text
            yourProfileVC.password = passwordTextField.text
            self.navigationController?.pushViewController(yourProfileVC, animated: true)
        }
        
    }
    

    
    @IBAction func emailEditingChanged(_ sender: Any) {
        if emailTextField.text!.isValidEmail && passwordTextField.text!.isValidPassword {
            nextButton.isEnabled = true
            return
        }
        
        nextButton.isEnabled = false
    
    }
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        
        if emailTextField.text!.isValidEmail && passwordTextField.text!.isValidPassword {
            nextButton.isEnabled = true
            return
        }

        nextButton.isEnabled = false

        
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // set the scene's title
        self.view.endEditing(true)
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        textField.resignFirstResponder()
        return true
    }
    
}
