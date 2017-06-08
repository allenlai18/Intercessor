//
//  AddNewFriendTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/23/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendRequestButton: UIButton!
    
    var isFriendRequest: Bool!
    {
        didSet {
            if isFriendRequest! {
                friendRequestButton.setImage(UIImage(named: "ConfirmButton"), for: UIControlState())
                friendRequestButton.setImage(UIImage(named: "ConfirmButtonSelected"), for: .selected)
            } else {
                friendRequestButton.setImage(UIImage(named: "AddButton"), for: UIControlState())
                friendRequestButton.setImage(UIImage(named: "AddButtonSelected"), for: .selected)
            }
        }
    }
    
    var friend: User!
    
    var user: (username:String, displayname:String, uid:String)! {  // for having a dictionary of friends
        didSet {
            Helper.usersRef.child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                self.friend = User(snapshot: snapshot)
            })
            displayNameLabel.text = user.displayname
            usernameLabel.text = "@" + user.username
        }
    }
    
    var userUID: String! {      // for accepting a friend request
        didSet {
            Helper.usersRef.child(userUID).observeSingleEvent(of: .value, with: { snapshot in
                self.friend = User(snapshot: snapshot)
                // get displayName
                DispatchQueue.main.async(execute: {
                    self.displayNameLabel.text = self.friend.displayName
                    self.usernameLabel.text = "@" + self.friend.username
                })
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func sendFriendRequestButtonTapped(_ sender: AnyObject) {
        if friendRequestButton.isSelected {
            return
        }
        if !isFriendRequest {
            
            friendRequestButton.isSelected = true
//            Helper.helper.sendFriendRequest(friend.uid)
            // TODO:: take out the user in allUsers in the VC after its added
            
            
        } else {

            friendRequestButton.isSelected = true
//            Helper.helper.addToFriends(friend.uid)
            
        }
    }
    

    
}




