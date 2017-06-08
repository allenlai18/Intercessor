//
//  ProfileHeaderTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 11/9/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {
    
    var parentVC: UIViewController!
    var user: User! {
        didSet {
            self.profileImageView.loadImageUsingCacheWithUrlString(user.profilePicURL)
            loadUpLabels()
            if user.uid == UserRepo.currentUser.uid {
                friendRelationshipButton.setImage(UIImage(named: "SettingsButton"), for: .normal)
                friendRelationshipButton.setTitle("SettingsButton", for: .normal)
            } else {
                loadRelationshipButton()
            }
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var numberOfFriendsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var verifiedImage: UIImageView!
    @IBOutlet weak var friendRelationshipButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = 55/2
        self.profileImageView.clipsToBounds = true
        self.verifiedImage.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileHeaderTableViewCell.listFriends))
        numberOfFriendsLabel.isUserInteractionEnabled = true
        numberOfFriendsLabel.addGestureRecognizer(tapGesture)
        
    }
    
    func listFriends() {
        if let _ = parentVC as? ProfileVC {
            Segues.showCurrentUsersListAllFriends(navigationController: parentVC.navigationController!)
        } else if let _ = parentVC as? ViewProfileVC {
            Segues.showListAllFriends(user: user, navigationController: parentVC.navigationController!)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func loadUpLabels() {
        numberOfFriendsLabel.text = String(user.friends.count)
        displayNameLabel.text = user.displayName
        usernameLabel.text = "@" + user.username
        if user.posts.count == 1 {
            numberOfPostsLabel.text = "1 Post"
        } else {
            numberOfPostsLabel.text = String(user.posts.count) + " Posts"
        }
        bioLabel.text = user.bio
        if user.verifiedStatus {
            self.verifiedImage.isHidden = false
        }
        
    }
    
    func loadRelationshipButton() {
        // 0 -> friends  ; 1 -> friendRequestSent  ; 2 -> friendRequestRecieved ; 3 -> not friends
        let relationship = Relationship.findRelationshipWithUser(userID: user.uid)
        if relationship == .friends {
            friendRelationshipButton.setImage(UIImage(named: "FriendButton"), for: .normal)
            friendRelationshipButton.setTitle("Friend", for: .disabled)
        } else if relationship == .friendRequestSent {
            friendRelationshipButton.setImage(UIImage(named: "AddedFriendButton"), for: .normal)
            friendRelationshipButton.setTitle("AddedFriend", for: .disabled)
        } else if relationship == .friendRequestReceived {
            friendRelationshipButton.setImage(UIImage(named: "ConfirmButton"), for: .normal)
            friendRelationshipButton.setTitle("Confirm", for: .disabled)
        } else if relationship == .notFriends {
            friendRelationshipButton.setImage(UIImage(named: "AddFriendButton"), for: .normal)
            friendRelationshipButton.setTitle("AddFriend", for: .disabled)
        }
    }
    @IBAction func friendRelationshipButtonTapped(_ sender: Any) {
        if friendRelationshipButton.title(for: .disabled) == "Confirm" {
            FriendAction.addToFriends(friendID: user.uid)
            friendRelationshipButton.setImage(UIImage(named: "ConfirmedButton"), for: .normal)
            friendRelationshipButton.setTitle("Confirmed", for: .disabled)
        } else if friendRelationshipButton.title(for: .disabled) == "AddFriend" {
            FriendAction.sendFriendRequest(userID: user.uid)
            friendRelationshipButton.setImage(UIImage(named: "AddedFriendButton"), for: .normal)
            friendRelationshipButton.setTitle("AddedFriend", for: .disabled)
        }
    }
}







