//
//  SendToVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import Firebase


protocol SendToVCDelegate {
    func clearFields()
}

class SendToVC: UIViewController {
    
    var delegate: SendToVCDelegate!
    
    var subject: String!
    var descrip: String!
    var postType: Post.PostType!
    var postPrivacy: Post.PostPrivacy = .public
    
    var checkedIndices: NSMutableArray = NSMutableArray()
    var friendUIDsToSend: [String] = [String]()
    var groupIDsToSend: [String] = [String]()
    
    let notification = ALNotification()
    
    
    // to prevent extra cells being selected
    @IBOutlet weak var sendToTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAnalytics.logEvent(withName: "Send_To", parameters: nil)

        sendToTableView.tableFooterView = UIView()
        self.checkedIndices.add(IndexPath(row: 0, section: 0))
        
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        
        let newPost = Post(userID: UserRepo.currentUser.uid, title: subject, descrip: descrip, postType: postType, privacy: postPrivacy, friendsToSend: friendUIDsToSend, groupsToSend: groupIDsToSend)
        newPost.saveNewPost()
        
        self.delegate?.clearFields()
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
        var message: String
        if newPost.postType == .praise {
            message = "Praise report posted"
        } else {
            message = "Prayer request posted"
        }
        notification.success("Success", message: message)
        
    }
    
    
}
/*
 
 3 sections
 - Personal (private); My Profile Page(public) -> header = "public/private"
 - Post to groups; list of all groups -> header = "Post to Groups"
 - Post to friends; list of all friends -> header = "Direct Message to Friends"
 */

extension SendToVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return UserRepo.currentUser.allFriendsRepo.currFriends.count
        default:
            print("Error: too many sections - numberOfRowsInSection", terminator: "")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "send to cell", for: indexPath) as! SendToTableViewCell
        cell.delegate = self
        cell.index = indexPath
        if checkedIndices.contains(indexPath) {
            cell.isChecked = true
        } else {
            cell.isChecked = false
        }
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.isChecked = true
                cell.titleLabel.text = "My Profile Page (public)"
            case 1:
                cell.titleLabel.text = "Friends Only (friends)"
            case 2:
                cell.titleLabel.text = "Personal (private)"
            default:
                print("Error: too many rows - indexpath 0", terminator: "")
            }
            
        case 1:
            cell.friend = UserRepo.currentUser.allFriendsRepo.currFriends[indexPath.row]
        default:
            print("Error: too many sections - cellForRowAtIndexPath", terminator: "")
        }
        
        return cell
    }

}


extension SendToVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).section == 0 {
            if indexPath.row == 0 {
                makePublic()
                return
            } else if indexPath.row == 1 { // when friend is selected
                makeFriendsOnly()
                return
            } else if indexPath.row == 2 { // when private is selected
                makePrivate()
                friendUIDsToSend.removeAll()
                groupIDsToSend.removeAll()
                // uncheck all the other cells
                for i in 0 ..< sendToTableView.numberOfRows(inSection: 1) {
                    let indexPath: IndexPath = IndexPath(row: i, section: 1)
                    if let cell = sendToTableView.cellForRow(at: indexPath) as? SendToTableViewCell {
                        cell.isChecked = false
                    }
                }
                //                for i in 0 ..< sendToTableView.numberOfRows(inSection: 2) {
                //                    let indexPath: IndexPath = IndexPath(row: i, section: 2)
                //                    if let cell = sendToTableView.cellForRow(at: indexPath) as? SendToTableViewCell {
                //                        cell.isChecked = false
                //
                //                    }
                //                }
                return
            }
        }
        // a group or friend is selected
        if postPrivacy == .private {
            self.makePublic()
        }
        if let cell = sendToTableView.cellForRow(at: indexPath) as? SendToTableViewCell {
            cell.isChecked = !cell.isChecked
            if cell.checkButton.isSelected {
                checkedIndices.add(indexPath)
                if let friend = cell.friend {
                    friendUIDsToSend.append(friend.uid)
                } else if let group = cell.group {
                    groupIDsToSend.append(group.groupID)
                }
            } else {
                // if unchecked
                // find the friend that needs to be deleted
                if let cellFriend = cell.friend {
                    var counter = 0
                    for friendUID in friendUIDsToSend {
                        if friendUID == cellFriend.uid {
                            self.friendUIDsToSend.remove(at: counter)
                            self.checkedIndices.remove(indexPath)
                        }
                        counter += 1
                    }
                } else {
                    // find the group that needs to be deleted
                    var counter = 0
                    for groupID in groupIDsToSend {
                        if groupID == cell.group.groupID {
                            self.groupIDsToSend.remove(at: counter)
                            self.checkedIndices.remove(indexPath)
                        }
                        counter += 1
                    }
                }
            }
        }
    }
    
    func makePublic() {
        postPrivacy = .public
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SendToTableViewCell {
            cell.isChecked = true
        }
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SendToTableViewCell {
            cell.isChecked = false
        }
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SendToTableViewCell {
            cell.isChecked = false
        }
    }
    func makeFriendsOnly() {
        postPrivacy = .friendsOnly
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SendToTableViewCell {
            cell.isChecked = false
        }
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SendToTableViewCell {
            cell.isChecked = true
        }
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SendToTableViewCell {
            cell.isChecked = false
        }
    }
    func makePrivate() {
        postPrivacy = .private
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SendToTableViewCell {
            cell.isChecked = false
        }
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SendToTableViewCell {
            cell.isChecked = false
        }
        if let cell = sendToTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SendToTableViewCell {
            cell.isChecked = true
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Public/Friends/Private"
//        case 1:
//            return "Post to Groups"
        case 1:
            return "Direct Message to Friends"
        default:
            print("Error: in function titleForHeaderInSection", terminator: "")
            return "error"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView   //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clear
        header.backgroundView!.backgroundColor = UIColor.clear
        
        header.textLabel!.textColor = UIColor.hex("AC2A3A", alpha: 1)
        header.textLabel!.font = UIFont(name: "Avenir-Book", size: 12)
        
        // add seperator to the top of the section header
        let sepFrame = CGRect(x: 0, y: 0, width: 600, height: 1)
        let seperatorView = UIView(frame: sepFrame)
        seperatorView.backgroundColor = UIColor.white
        header.addSubview(seperatorView)
    }
    
}

extension SendToVC: SendToDelegate {
    
    func checkButtonTappedAdd(_ indexPath: IndexPath) {
        tableView(sendToTableView, didSelectRowAt: indexPath)
    }
    
}


