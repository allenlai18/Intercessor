//
//  YourProfileVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/10/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Photos
import FirebaseStorage


class YourProfileVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: PaddedTextField!
    @IBOutlet weak var nextButton: FadedButton!
    
    
    var email: String!
    var password: String!
    // set in the VC from user
    var displayName:String!
    
    
    fileprivate var profileImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImageView.layer.cornerRadius = 100/2
        self.profileImageView.clipsToBounds = true
    
        fullNameTextField.delegate = self
        fullNameTextField.becomeFirstResponder()
        fullNameTextField.roundTextField()
        fullNameTextField.setLeftImageToFullName()

        nextButton.isEnabled = false
        
        
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
    
    
    

    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if nextButton.isEnabled {
            // perform segue and pass info
            let authSB = UIStoryboard(name: "Auth", bundle: nil)
            let vc = authSB.instantiateViewController(withIdentifier: "ChooseUsername") as! ChooseUsernameVC
            vc.email = email
            vc.password = password
            vc.displayName = fullNameTextField.text
            
            vc.profilePicture = profileImage
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
    }

    
    
    @IBAction func fullNameTextFieldEditingChanged(_ sender: Any) {
        if fullNameTextField.text != "" {
            nextButton.isEnabled = true
            return
        }
        
        nextButton.isEnabled = false
        
    }
    
    
    
    func presentCamera()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func profileImageViewTapped(_ sender: Any) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.profileImageViewTapped(sender)
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
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)

    }

}


extension YourProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profileImageView.image! = self.profileImage!
        picker.dismiss(animated: true, completion: nil)
    }
}




