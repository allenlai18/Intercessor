//
//  ForgotPasswordVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/12/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseAuth


class ForgotPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var sendButton: FadedButton!
    
    let notification = ALNotification()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.roundTextField()
        emailTextField.setLeftImageToEmail()
        emailTextField.becomeFirstResponder()
        sendButton.isEnabled = false
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailTextField.text!) { error in
            if let error = error {
                self.notification.error("Error", message: error.localizedDescription)
            } else {
                // Password reset email sent.
                self.notification.success("Success", message: "Password reset email sent")
            }
        }
    }

    @IBAction func emailTextFieldEditingChanged(_ sender: Any) {
        if emailTextField.text!.isValidEmail {
            sendButton.isEnabled = true
            return
        }
        sendButton.isEnabled = false
    }
    


    @IBAction func back(_ sender: Any) {

        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // set the scene's title
        self.view.endEditing(true)
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
