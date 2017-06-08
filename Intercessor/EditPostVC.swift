//
//  EditPostVC.swift
//  Intercessor
//
//  Created by Allen Lai on 11/24/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class EditPostVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    let notification = ALNotification()

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    var postType: Post.PostType = .prayer

    // needs to be set before loaded
    var post: Post!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.loadImageUsingCacheWithUrlString(UserRepo.currentUser.profilePicURL)
        
        displayNameLabel.text = UserRepo.currentUser.displayName
        
        // adding the DVswitch - customized switch
        let switcher = DVSwitch(stringsArray: ["🙏", "🙌"])
        switcher?.frame = CGRect(x: self.view.frame.size.width - 20 - 120, y: 95, width: 120, height: 35)
        switcher?.sliderColor = UIColor.hex("AC2A3A", alpha: 1)
        switcher?.layer.borderWidth = 1
        switcher?.layer.borderColor = UIColor.hex("AC2A3A", alpha: 1).cgColor
        switcher?.layer.cornerRadius = 15
        switcher?.font = UIFont(name: "Avenir", size: 14)
        switcher?.labelTextColorInsideSlider = UIColor(white: 1, alpha: 1)
        switcher?.labelTextColorOutsideSlider = UIColor.hex("AC2A3A", alpha: 1)
        switcher?.backgroundColor = UIColor(white: 1, alpha: 0)
        
        mainView?.addSubview(switcher!)
        switcher?.setPressedHandler { (index) -> Void in
            if index == 0 {
                self.postType = .prayer
            } else {
                self.postType = .praise
            }
        }
        
        // set old post
        self.titleTextField.text = post.title
        self.descriptionTextView.text = post.descrip
        if post.postType == .praise {
            switcher?.select(1, animated: true)
        }
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            self.view.endEditing(true)
            descriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }
    

    @IBAction func dismiss(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        // delete all old hashTags
        for hashTagString in post.hashTags {
            if hashTagString.isValidHashTag{
                Helper.hashTagsRef.child(hashTagString).child(self.post.postID).setValue(nil)
            }
        }
        
        post.title = self.titleTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        post.descrip = self.descriptionTextView.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        post.postType = self.postType
        post.updatePost()
        
        notification.success("Success", message: "Post updated")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == titleTextField {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 25
        }
        return true
    }
    
    

}






