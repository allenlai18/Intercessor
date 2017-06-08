//
//  CommentTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/26/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeDateLabel: UILabel!
    
    var commentUser: User! {
        didSet {
            self.displayNameLabel.text = self.commentUser.displayName    // set display Label
            self.profileImageView.loadImageUsingCacheWithUrlString(self.commentUser.profilePicURL)
        }
    }
    
    var cellComment: Comment! {
        didSet {
            detailLabel.text = cellComment.content
            timeDateLabel.text = dateTimeFormattedAsTimeAgo(cellComment.date)
            // fetch friend
            AllFriendsRepo.sharedInstance.fetchUser(userID: cellComment.userID) { (userFound) in
                self.commentUser = userFound
            }
        }

    }
    
    
    
    // for the first cell
    var poster: User! {
        didSet {
            self.profileImageView.loadImageUsingCacheWithUrlString(poster.profilePicURL)
            self.displayNameLabel.text = poster.displayName
        }
    }
    var postForFirstCell: Post! {
        didSet {
            self.timeDateLabel.text = dateTimeFormattedAsTimeAgo(postForFirstCell.date)
            var detailText = ""
            switch postForFirstCell.postType {
            case .prayer:
                detailText += "🙏 "
            case .praise:
                detailText += "🙌 "
            }
            detailText += postForFirstCell.title + ": "
            detailText += postForFirstCell.descrip
            self.detailLabel.text = detailText
            
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
    
    
    
    override func prepareForReuse() {
        profileImageView.image = nil
        displayNameLabel.text = nil
        detailLabel.text = nil
        timeDateLabel.text = nil
        
    }

}



