//
//  FriendTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!
    
    
    var friend: User! {
        didSet {
            self.profileImageView.loadImageUsingCacheWithUrlString(self.friend.profilePicURL)
            self.displayNameLabel.text = self.friend.displayName
            self.userHandleLabel.text = "@" + self.friend.username
            if friend.uid == UserRepo.currentUser.uid {
                relationshipButton.isHidden = true
            } else {
                loadRelationshipButton()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImageView.layer.cornerRadius = 20
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        relationshipButton.isHidden = false
    }

    
    func loadRelationshipButton() {
        // 0 -> friends  ; 1 -> friendRequestSent  ; 2 -> friendRequestRecieved ; 3 -> not friends
        let relationship = Relationship.findRelationshipWithUser(userID: friend.uid)
        if relationship == .friends {
            relationshipButton.setImage(UIImage(named: "FriendButton"), for: .normal)
            relationshipButton.setTitle("Friend", for: .disabled)
        } else if relationship == .friendRequestSent {
            relationshipButton.setImage(UIImage(named: "AddedFriendButton"), for: .normal)
            relationshipButton.setTitle("AddedFriend", for: .disabled)
        } else if relationship == .friendRequestReceived {
            relationshipButton.setImage(UIImage(named: "ConfirmButton"), for: .normal)
            relationshipButton.setTitle("Confirm", for: .disabled)
        } else if relationship == .notFriends {
            relationshipButton.setImage(UIImage(named: "AddFriendButton"), for: .normal)
            relationshipButton.setTitle("AddFriend", for: .disabled)
        }
    }
    
    @IBAction func relationshipButtonTapped(_ sender: Any) {
        if relationshipButton.title(for: .disabled) == "Confirm" {
            FriendAction.addToFriends(friendID: friend.uid)
            relationshipButton.setImage(UIImage(named: "ConfirmedButton"), for: .normal)
            relationshipButton.setTitle("Confirmed", for: .disabled)
        } else if relationshipButton.title(for: .disabled) == "AddFriend" {
            FriendAction.sendFriendRequest(userID: friend.uid)
            relationshipButton.setImage(UIImage(named: "AddedFriendButton"), for: .normal)
            relationshipButton.setTitle("AddedFriend", for: .disabled)
        }
        // doesnt do anything if its anything else
    }
 
    
    
    
}






