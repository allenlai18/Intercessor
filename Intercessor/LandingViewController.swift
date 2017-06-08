//
//  ViewController.swift
//  Intercessor
//
//  Created by Allen Lai on 8/16/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import LilithProgressHUD


class LandingViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, TTTAttributedLabelDelegate {

    
    @IBOutlet weak var termsAndServicesLabel: TTTAttributedLabel!
    @IBOutlet weak var facebookLoginButton: UIButton!
    let notification = ALNotification()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = "503225204389-jq3vpk055msggg72ihrpmurp7elo1rmb.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        
        // Attributed Label stuff
        termsAndServicesLabel.delegate = self
        let wholeRange = NSMakeRange(0, 55)
        let termsRange = NSMakeRange(31, 5)
        let privatePolicyRange = NSMakeRange(41, 14)
        let attributedString = NSMutableAttributedString(string: termsAndServicesLabel.text!)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: wholeRange)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato", size: 18)!, range: wholeRange)
        
        termsAndServicesLabel.attributedText = attributedString
        termsAndServicesLabel.linkAttributes = [NSForegroundColorAttributeName: UIColor.white, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]
        termsAndServicesLabel.addLink(to: URL(string: "https://docs.google.com/document/d/1UeYVMwjXwAgbDvnQM-wvCQzb_fT6MvOsWsI4zoO4wSA/edit?usp=sharing") as URL!, with: termsRange)           // Change link here
        termsAndServicesLabel.addLink(to: URL(string: "https://docs.google.com/document/d/1fuVgIeupLRfIzKtxCvsr1BYeamsiokOoY18RhuxsAPU/edit?usp=sharing") as URL!, with: privatePolicyRange)
        
        
    }
    

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }

    @IBAction func googleLoginButtonTapped(_ sender: AnyObject) {

        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        LilithProgressHUD.show()

        // use this to access the users google information
        let credential = FIRGoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
        
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                LilithProgressHUD.hide()
                
                print(error!.localizedDescription)
                self.notification.error("Error", message: error!.localizedDescription)

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
                        self.segueToUsername(firebaseUser: user!)

                    }
                })
            }
        })
    }

    @IBAction func facebookLoginButtonTapped(_ sender: AnyObject) {
        let loginManager = FBSDKLoginManager()

        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self, handler: { (result, error) -> Void in
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
    
    func segueToUsername(firebaseUser: FIRUser) {
        let AuthSB = UIStoryboard(name: "Auth", bundle: nil)
        let usernameVC = AuthSB.instantiateViewController(withIdentifier: "ChooseUsername") as! ChooseUsernameVC
        usernameVC.user = firebaseUser
        self.navigationController?.pushViewController(usernameVC, animated: true)
    }

    
}












