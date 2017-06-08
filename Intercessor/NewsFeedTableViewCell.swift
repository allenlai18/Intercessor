//
//  HomeTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 9/12/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class NewsFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    
    var parentVC: UIViewController!
    
    var user: User! {
        didSet {
            profileImageView.loadImageUsingCacheWithUrlString(user.profilePicURL)
            displayNameLabel.text = user.displayName
        }
    }
    var cellPost: Post! {
        didSet {
                        
            if let friend = AllFriendsRepo.sharedInstance.fetchFriendFromCache(cellPost.userID) {
                self.user = friend
            } else {
                // this post cell is from ProfileVC
                profileImageView.loadImageUsingCacheWithUrlString(UserRepo.currentUser.profilePicURL)
                displayNameLabel.text = UserRepo.currentUser.displayName
            }

            timeAgoLabel.text = dateTimeFormattedAsTimeAgo(cellPost.date)
            var content: String = ""
            if cellPost.postType == .prayer {
                content = "🙏"
            } else {
                content = "🙌"
            }
            content += cellPost.title + ": " + cellPost.descrip
            postContentLabel.text = content
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.layer.cornerRadius = 20
        self.profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showProfile))
        singleTap.numberOfTapsRequired = 1;
        profileImageView.addGestureRecognizer(singleTap)
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showProfile() {
        Segues.showProfile(user: user, navigationController: parentVC.navigationController!)
    }
    
}
