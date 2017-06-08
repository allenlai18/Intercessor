//
//  GroupMembersTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/29/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class GroupMembersTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var friend: User! {
        didSet {
            displayNameLabel.text = friend.displayName
            self.profileImageView.loadImageUsingCacheWithUrlString(friend.profilePicURL)
            userNameLabel.text = friend.username
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

}
