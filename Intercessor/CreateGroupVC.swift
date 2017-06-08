//
//  CreateGroupVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/23/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Photos


class CreateGroupVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var groupPictureImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var noFriendsToAddLabel: UILabel!
    
    
    fileprivate var groupImage: UIImage = UIImage(named: "defaultProfileImage")!

    var checkedIndices: NSMutableArray = NSMutableArray()
    var friendsInTheGroup: [User] = [User]()
    var friendsIDinTheGroup: [String] = [String]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI Stuff
        noFriendsToAddLabel.isHidden = true
        // make profileImage rounded
        self.groupPictureImageView.layer.cornerRadius = 70/2
        self.groupPictureImageView.clipsToBounds = true
        
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.white.cgColor
        titleTextField.layer.cornerRadius = 10
        allFriendsTableView.tableFooterView = UIView()
        
        
        
    }
    
    // MARK:: text field delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    @IBAction func dismiss(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        let groupName = titleTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        for friend in friendsInTheGroup {
            friendsIDinTheGroup.append(friend.uid)
        }
        friendsIDinTheGroup.append(UserRepo.currentUser.uid)
        
        let newGroup = Group(name: groupName, users: friendsIDinTheGroup)
        newGroup.saveNewGroup(groupImage)
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
        
        // notifications sent out
        for friend in friendsInTheGroup {
            let groupNoti = Notification(ownerID: friend.uid, subjectID: friend.uid, action: .joined, object: .group, objectID: newGroup.groupID)
            groupNoti.saveNewNotification()
        }
        

    }
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickProfileImage(_ sender: AnyObject) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.pickProfileImage(sender)
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
                        self.groupImage = images[0]!
                        self.groupPictureImageView.image = self.groupImage
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .cancel, handler: { (_) -> () in
                self.groupImage = UIImage(named: "defaultProfileImage")!
                self.groupPictureImageView.image = UIImage(named: "defaultProfileImage")
                }, secondaryHandler: nil))
            present(controller, animated: true, completion: nil)
        }
        
    }

}



extension CreateGroupVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserRepo.currentUser.allFriendsRepo.currFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "add friend cell", for: indexPath) as! CreateGroupTableViewCell
        cell.delegate = self
        
        
        cell.index = indexPath
        if checkedIndices.contains(indexPath) {
            cell.isChecked = true
        } else {
            cell.isChecked = false
        }
        cell.friendUser = UserRepo.currentUser.allFriendsRepo.currFriends[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Add Friends to the Group"
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView   //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clear
        header.backgroundView!.backgroundColor = UIColor.clear
        
        header.textLabel!.textColor = UIColor(red: 140.0/255.0, green: 136.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "Avenir-Book", size: 12)
    }
}

extension CreateGroupVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupTableViewCell {
            cell.checkButton.isSelected = !cell.checkButton.isSelected
            let friendinCell = cell.friendUser
            
            // if it turned checked
            if cell.checkButton.isSelected {
                checkedIndices.add(indexPath)
                friendsInTheGroup.append(friendinCell!)
                
            } else {
                // find the contact that needs to be deleted
                var counter = 0
                for friend in friendsInTheGroup {
                    if friend.uid == cell.friendUser.uid {
                        self.friendsInTheGroup.remove(at: counter)
                        self.checkedIndices.remove(indexPath)
                    }
                    counter += 1
                }
            }
        }
    }
    
}

extension CreateGroupVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.groupImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.groupPictureImageView.image! = self.groupImage
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupVC: CreateGroupDelegate {
    
    func checkButtonTappedAdd(_ indexPath: IndexPath) {
        tableView(allFriendsTableView, didSelectRowAt: indexPath)
    }
    
}

