//
//  UserCell.swift
//  Odio
//
//  Created by Xavier Sharp on 12/17/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    

    var isCurrentUserProfile: Bool = false
    var parentVC: SearchViewController!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var verifiedIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var user: User! {
        didSet {
            loadData(user)
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userProfilePic.image   = nil
//        self.verifiedIcon.hidden    = true
        self.usernameLabel.text     = nil
        self.nameLabel.text         = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userProfilePic.image   = nil
        self.verifiedIcon.isHidden  = true
        self.usernameLabel.text     = nil
        self.nameLabel.text         = nil
    }

    @IBAction func userButtonTapped(_ sender: UIButton) {
        // the whole cell
        Segues.showProfile(user: user, navigationController: parentVC.navigationController!)
        
        
    }

    @IBAction func addButtonTapped(_ sender: AnyObject) {
        if addButton.isSelected {
            return
        }
        if addButton.title(for: .normal) == "AddButton" {
            addButton.setImage(UIImage(named: "AddButtonSelected"), for: .selected)
            addButton.isSelected = true
//            Helper.helper.sendFriendRequest(user.uid)
        } else if addButton.title(for: .normal) == "ConfirmButton" {
            addButton.setImage(UIImage(named: "ConfirmButtonSelected"), for: .selected)
            addButton.isSelected = true
//            Helper.helper.addToFriends(user.uid)   
        }
    }

    func loadData(_ user: User) {
        checkIfCurrentUsersProfile()
        setProfilePicture()
        setUserDetails()
        checkRelationship()
    }
    

    
    func setProfilePicture() {
        userProfilePic.loadImageUsingCacheWithUrlString(self.user.profilePicURL)
    }
    
    func setUserDetails() {
        usernameLabel.text  = "@\(user.username)"
        nameLabel.text = user.displayName
        if user.verifiedStatus {
            verifiedIcon.isHidden = false
        } else {
            verifiedIcon.isHidden = true
        }
    }
    
    func checkRelationship() {
        if AllFriendsRepo.sharedInstance.fetchFriendFromCache(user.uid) != nil {
            // Person is already a friend
            addButton.isSelected = true
            addButton.setImage(UIImage(named: "FriendButton"), for: .selected)
        } else if UserRepo.currentUser.friendRequestsReceived.contains(user.uid) {
            // Person already sent a friend request
            addButton.setImage(UIImage(named: "ConfirmButton"), for: .normal)
            addButton.setTitle("ConfirmButton", for: .normal)
        } else if UserRepo.currentUser.friendRequestsSent.contains(user.uid) {
            // Already a friend
            addButton.isSelected = true
            addButton.setImage(UIImage(named: "ConfirmButtonSelected"), for: .selected)
        } else {
            // Not a friend yet
            addButton.setImage(UIImage(named: "AddButton"), for: .normal)
            addButton.setTitle("AddButton", for: .normal)

        }

    }

    func checkIfCurrentUsersProfile() {
        if user.uid == UserRepo.currentUser.uid {
            isCurrentUserProfile = true
        }
    }



    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
