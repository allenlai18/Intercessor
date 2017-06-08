//
//  GroupPostsTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/28/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class GroupPostsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var postDetailsLabel: UILabel!
    @IBOutlet weak var timeDateLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    var user: User!
    var cellPost: Post! {
        didSet {
            timeDateLabel.text = dateTimeFormattedAsTimeAgo(self.cellPost.date)
            switch cellPost.postType {
            case .prayer:
                postDetailsLabel.text = "🙏: " + cellPost.title
            case .praise:
                postDetailsLabel.text = "🙌: " + cellPost.title
            }
            if self.cellPost.comments.count == 1 {
                self.numberOfCommentsLabel.text = "1 comment"
            } else {
                self.numberOfCommentsLabel.text = String(self.cellPost.comments.count) + " comments"
            }
            Helper.usersRef.child(self.cellPost.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                self.user = User(snapshot: snapshot)
                DispatchQueue.main.async(execute: {
                    self.displayNameLabel.text = self.user.displayName
                    self.profileImageView.loadImageUsingCacheWithUrlString(self.user.profilePicURL)
                })
            })

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // make profileImage rounded
        self.profileImageView.layer.cornerRadius = 20
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
