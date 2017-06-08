//
//  LoginVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/11/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import LilithProgressHUD



class LoginVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {

    
    
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var passwordTextField: PaddedTextField!
    @IBOutlet weak var loginButton: FadedButton!
    
    let notification = ALNotification()


    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = "503225204389-jq3vpk055msggg72ihrpmurp7elo1rmb.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

        emailTextField.roundTextField()
        emailTextField.setLeftImageToEmail()
        passwordTextField.roundTextField()
        passwordTextField.setLeftImageToPassword()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.becomeFirstResponder()

        
        loginButton.isEnabled = false

    }

    @IBAction func googleLoginTapped(_ sender: Any) {
        LilithProgressHUD.show()

        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookLoginTapped(_ sender: Any) {
        LilithProgressHUD.show()
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
            if (error == nil){
                
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        LilithProgressHUD.hide()
                        
                        self.notification.error("Error", message: error!.localizedDescription)
                        print(error!.localizedDescription)
                        return
                    } else {
                        // check if they are already have a username to their account in the database
                        Helper.usersRef.child(user!.uid).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                            print(snapshot)
                            LilithProgressHUD.hide()
                            if snapshot.exists() {
                                // automatically log them in
                                Helper.helper.switchToMainApp()
                            } else {
                                // tell them to go to the set up a username, because they never logged in
                                self.segueToUsername(firebaseUser: user!)
                            }
                        })
                        
                    }
                })
            }
        })
    }
    
    @IBAction func emailEditingChanged(_ sender: Any) {
        if emailTextField.text!.isValidEmail && passwordTextField.text!.isValidPassword {
            loginButton.isEnabled = true
            return
        }
        loginButton.isEnabled = false
    }
    
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        if emailTextField.text!.isValidEmail && passwordTextField.text!.isValidPassword {
            loginButton.isEnabled = true
            return
        }
        
        loginButton.isEnabled = false
        
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        // email login
        LilithProgressHUD.show()
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                LilithProgressHUD.hide()

                print(error!.localizedDescription)
                self.notification.error("Error", message: error!.localizedDescription)
                return
            } else {
                LilithProgressHUD.hide()
                Helper.helper.switchToMainApp()
            }
        }
        
    }

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        // use this to access the users google information
        let credential = FIRGoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                LilithProgressHUD.hide()
                self.notification.error("Error", message: error!.localizedDescription)
                print(error!.localizedDescription)
                return
            } else {
                // check if they are already have a username to their account in the database
                Helper.usersRef.child(user!.uid).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                    LilithProgressHUD.hide()
                    if snapshot.exists() {
                        // automatically log them in
                        Helper.helper.switchToMainApp()
                    } else {
                        // tell them to go to the set up a username, because they never logged in
                        self.performSegue(withIdentifier: "username", sender: user)
                    }
                })
                
            }
        })
    }
    @IBAction func back(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "forgot password", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "username" {
            let usernameViewController = segue.destination as! UsernameVC
            usernameViewController.user = sender as? FIRUser
        }
    }
    
    
    func segueToUsername(firebaseUser: FIRUser) {
        let AuthSB = UIStoryboard(name: "Auth", bundle: nil)
        let usernameVC = AuthSB.instantiateViewController(withIdentifier: "ChooseUsername") as! ChooseUsernameVC
        usernameVC.user = firebaseUser
        self.navigationController?.pushViewController(usernameVC, animated: true)
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
    
    private func textFieldDidBeginEditing(_ textField: UITextField) -> Bool {
        self.navigationItem.title = ""
        return true
    }
    
    private func textFieldDidEndEditing(_ textField: UITextField) -> Bool {
        self.navigationItem.title = "Login"
        return true
    }

    
    
    
}
