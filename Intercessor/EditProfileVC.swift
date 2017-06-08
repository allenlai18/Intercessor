//
//  EditProfileVC.swift
//  Intercessor
//
//  Created by Allen Lai on 9/29/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet var phoneButton: UIButton!
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let notification = ALNotification()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification.error(nil, message: "edit profile feature doesn't work yet")
        setFields()
    }

    func setFields() {
        avatarImageView.loadImageUsingCacheWithUrlString(UserRepo.currentUser.profilePicURL)
        
        nameTextField.text      = UserRepo.currentUser.displayName
        usernameTextField.text  = UserRepo.currentUser.username
        websiteTextField.text   = ""
        bioTextField.text       = UserRepo.currentUser.bio
        emailTextField.text     = UserRepo.currentUser.email
        phoneTextField.text     = ""
    }

    
    @IBAction func avatarTapped(_ sender: UIButton) {
        
        
        
//        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        var action1 = UIAlertAction(title: "Open camera", style: .default, handler: {(_ action: UIAlertAction) -> Void in
////            PresentPhotoCamera(self, true)
//        })
//        var action2 = UIAlertAction(title: "Photo library", style: .default, handler: {(_ action: UIAlertAction) -> Void in
////            PresentPhotoLibrary(self, true)
//        })
//        var action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(action1)
//        alert.addAction(action2)
//        alert.addAction(action3)
//        self.present(alert, animated: true, completion: { _ in })
    
    }
    
    @IBAction func phoneTapped(_ sender: UIButton) {
        print("EditProfileVC.swift - phoneTapped()")
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        notification.error(nil, message: "edit profile feature doesn't work yet")

    }

    func displayError(_ error: String) {
        notification.error(nil, message: error)
    }
    
    func resizeAndUploadAvatars() {
//        let avatar = XQAvatarCrop(image: self.avatarImageView.image)
//        self.user[kUserAvatarKey] = avatar.avatarKey
    }
    
    
    
    
    // MARK: - Validators
    
    func validUrl(_ urlString: String) -> Bool {
        let urlRegEx: String = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let urlTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: self.prepareUrl(urlString))
    }
    
    func prepareUrl(_ urlString: String) -> String {
        var url = urlString
        //        url.characters
        if url.characters.count > 0 {
            if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
                url = "http://\(url)"
            }
        }
        return url
    }
    
    
    

}

extension EditProfileVC: UIImagePickerControllerDelegate {
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {


    }
}


