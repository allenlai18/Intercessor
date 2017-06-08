//
//  AddVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Firebase

class AddVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    var postType: Post.PostType = .prayer
    
    let notification = ALNotification()

    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAnalytics.logEvent(withName: "Add_Post", parameters: nil)

        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.loadImageUsingCacheWithUrlString(UserRepo.currentUser.profilePicURL)
        
        displayNameLabel.text = UserRepo.currentUser.displayName

        
//        descriptionTextView.layer.borderWidth = 1
//        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
//        descriptionTextView.layer.cornerRadius = 7
        
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

        self.titleTextField.becomeFirstResponder()
    
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            self.view.endEditing(true)
            descriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }
    
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        let title = self.titleTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let descrip = self.descriptionTextView.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if title == "" || descrip == "" {
            notification.error("Error", message: "Title or Description Field can not be empty. 😅")
        } else {
            performSegue(withIdentifier: "sendTo", sender: nil)
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        if segue.identifier == "sendTo" {
            let sendToViewController = segue.destination as! SendToVC
            sendToViewController.subject = self.titleTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            sendToViewController.descrip = self.descriptionTextView.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            sendToViewController.postType = self.postType
            sendToViewController.delegate = self
        }
        
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



extension AddVC: SendToVCDelegate {
    func clearFields() {
        titleTextField.text = ""
        descriptionTextView.text = ""
    }
}



