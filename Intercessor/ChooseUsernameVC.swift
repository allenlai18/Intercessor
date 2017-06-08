//
//  ChooseUsernameVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/11/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ChooseUsernameVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameTextField: PaddedTextField!
    @IBOutlet weak var finishButton: FadedButton!
    
    
    let notification = ALNotification()
    
    var email: String!
    var password: String!
    var displayName: String!
    var profilePicture: UIImage!
    
    
    // came from landingPage
    var user: FIRUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.roundTextField()
        usernameTextField.setLeftImageToUsername()
        usernameTextField.delegate = self
        usernameTextField.becomeFirstResponder()
        
        finishButton.isEnabled = false
        
        
    }
    
    
    @IBAction func usernameEditingChanged(_ sender: Any) {
        if usernameTextField.text!.isValidUsername {
            finishButton.isEnabled = true
            return
        }
        
        finishButton.isEnabled = false
        
    }
    
    
    
    @IBAction func finishButtonTapped(_ sender: Any) {
        
        // create the account and enter in the main app
        let usernameTyped = usernameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if usernameTyped.characters.count < 4 {
            notification.error("Error", message: "Invalid username")
            return
        }
        
        // if user is creating account with social media link
        if user != nil {
            Helper.usernamesRef.child(usernameTyped).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.notification.error("Error", message: "Username already taken.")
                } else {
                    UserRepo.currentUser = UserRepo(uid: "\(self.user!.uid)", displayName: "\(self.user!.displayName!)", profilePicURL: "\(self.user!.photoURL!)")

                    UserRepo.currentUser.username = usernameTyped
                    UserRepo.currentUser.saveNewUser()
                    
                    // switch to app
                    Helper.helper.switchToMainApp()
                }
            })
            return
        }

        // if user is creating account with email
        FIRAuth.auth()?.createUser(withEmail: self.email, password: self.password) { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.notification.error("Error", message: error!.localizedDescription)
                return
            } else {
                print("creating profile")
                if self.profilePicture != nil { // if the user had a profilePicture or not
                    let filePath = usernameTyped
                    
                    let data = UIImageJPEGRepresentation(self.profilePicture!, 0.3)
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpg"
                    FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
                        in
                        if error != nil {
                            print(error?.localizedDescription)
                            
                            self.notification.error("Error", message: (error?.localizedDescription)!)

                            return
                        }
                        let fileUrl = metadata!.downloadURLs![0].absoluteString
                        
                        UserRepo.currentUser = UserRepo(uid: "\(user!.uid)", displayName: self.displayName, profilePicURL: fileUrl)
                        UserRepo.currentUser.email = self.email
                        UserRepo.currentUser.username = usernameTyped
                        UserRepo.currentUser.saveNewUser()
                        
                        // switch to app
                        Helper.helper.switchToMainApp()
                        
                    }
                    // if user did not use a profilePicture
                } else {
                    UserRepo.currentUser = UserRepo(uid: "\(user!.uid)", displayName: self.displayName, profilePicURL: "")
                    UserRepo.currentUser.email = self.email

                    UserRepo.currentUser.username = usernameTyped
                    UserRepo.currentUser.saveNewUser()
                    
                    // switch to app
                    Helper.helper.switchToMainApp()
                    
                    
                }
                
                
            }
        }
        


        
        
        
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
        textField.resignFirstResponder()
        return true
    }
    

}










