//
//  UsernameVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/23/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import LilithProgressHUD



class UsernameVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var user: FIRUser!
    fileprivate var profileImage: UIImage?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make profileImage rounded
        self.profileImageView.layer.cornerRadius = 100/2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.image = UIImage(data: try! Data(contentsOf: user!.photoURL!))
        
        
        useUnderline(usernameTextField)
        usernameTextField.delegate = self
        usernameTextField.becomeFirstResponder()
        
        UserRepo.currentUser = UserRepo(uid: "\(self.user!.uid)", displayName: "\(self.user!.displayName!)", profilePicURL: "\(self.user!.photoURL!)")
        
        
        
        
    }

    @IBAction func doneTapped(_ sender: AnyObject) {
        LilithProgressHUD.show()
        self.view.endEditing(true)
        // check if the username has been taken?
        print(UserRepo.currentUser.displayName)
        
        let usernameTyped = usernameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if usernameTyped.isEmpty || usernameTyped.characters.count < 4 {
            self.alert("Invalid username")
            return
        }
        
        Helper.usernamesRef.child(usernameTyped).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.alert("Username already taken. 😅")
                LilithProgressHUD.hide()
            } else {
                UserRepo.currentUser.username = usernameTyped
                UserRepo.currentUser.saveNewUser()
                
                LilithProgressHUD.hide()
                // switch to app
                Helper.helper.switchToMainApp()
            }
        })
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
    
    func alert(_ msg: String) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentCamera()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func changeProfilePicture(_ sender: AnyObject) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.changeProfilePicture(sender)
                })
            })
            return
        }
        
        if authorization == .authorized {
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "ActionTitle"),
                secondaryTitle: NSLocalizedString("Use this one", comment: "Action Title"),
                handler: { (_) -> () in
                    self.presentCamera()
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.profileImage = images[0]
                        self.profileImageView.image = self.profileImage
                        // save the profile picture
                        let filePath = "\(UserRepo.currentUser.uid)/\(Date.timeIntervalSinceReferenceDate)"
                        let data = UIImageJPEGRepresentation(self.profileImage!, 0.1)
                        let metadata = FIRStorageMetadata()
                        metadata.contentType = "image/jpg"
                        FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
                            in
                            if error != nil {
                                print(error?.localizedDescription)
                                return
                            }
                            let fileUrl = metadata!.downloadURLs![0].absoluteString
                            
                            // save the url path
                            UserRepo.currentUser.profilePicURL = fileUrl
                        }
                    })
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Default", comment: "Action Title"), handler: { (_) -> () in
                self.profileImage = nil
                self.profileImageView.image = UIImage(named: "defaultProfileImage")
                }, secondaryHandler: nil))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .cancel, handler: { (_) -> () in
                //                self.profileImage = nil
                //                self.profileImageView.image = UIImage(named: "defaultProfileImage")
                }, secondaryHandler: nil))
            
            present(controller, animated: true, completion: nil)
        }
    }
    func useUnderline(_ textfield: UITextField) {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: textfield.frame.size.height - borderWidth, width: textfield.frame.size.width, height: textfield.frame.size.height)
        border.borderWidth = borderWidth
        textfield.layer.addSublayer(border)
        textfield.layer.masksToBounds = true
    }
}

extension UsernameVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profileImageView.image! = self.profileImage!
        picker.dismiss(animated: true, completion: nil)
    }
}

