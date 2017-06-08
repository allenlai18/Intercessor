//
//  PostTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 11/4/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import ActiveLabel

class PostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiCaptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var numberOfComments: UILabel!
    
    var row: Int!
    var rowPlaying: Int!
    
    var parentVC: UIViewController!
    var user: User! {
        didSet {
            profileImageView.loadImageUsingCacheWithUrlString(user.profilePicURL)
            displayNameLabel.text = user.displayName
            
            // if it is other user, then tapping the picture does to the profile
            let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showProfile))
            singleTap.numberOfTapsRequired = 1;
            profileImageView.addGestureRecognizer(singleTap)
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
            var bufferForEmoji: String = ""
            var bufferForEmojiCaption: String = ""
            if self.cellPost.userID == UserRepo.currentUser.uid {
                switch self.cellPost.privacy {
                case .public:
                    bufferForEmoji += "🌐"
                    bufferForEmojiCaption += "public"
                case .friendsOnly:
                    bufferForEmoji += "👥"
                    bufferForEmojiCaption += "friends only"
                case .private:
                    bufferForEmoji += "🔒"
                    bufferForEmojiCaption += "private"
                }
            }
            switch self.cellPost.postType {
            case .prayer:
                bufferForEmoji += "🙏"
                bufferForEmojiCaption = "prayer"
            case .praise:
                bufferForEmoji += "🙌"
                bufferForEmojiCaption = "praise"
            }
            emojiLabel.text = bufferForEmoji
            emojiCaptionLabel.text = bufferForEmojiCaption
            
            titleLabel.text = cellPost.title
            descriptionLabel.text = cellPost.descrip
            descriptionLabel.handleHashtagTap { hashtag in

                Segues.goToHashTag(tagString: hashtag, navigationController: self.parentVC.navigationController!)
            }
            
            numberOfComments.text = String(cellPost.comments.count)     // numberOfComments gets a nil crash
            
            

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.layer.cornerRadius = 25
        
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFit
        self.profileImageView.backgroundColor = UIColor.white
        self.profileImageView.isUserInteractionEnabled = true
        

    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.displayNameLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    override func layoutSubviews() {
        self.cardSetup()
    }
    
    func cardSetup() {
        self.cardView.alpha = 1
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.cornerRadius = 7
        self.cardView.layer.shadowOffset = CGSize(width: -0.2, height: -0.2)
        self.cardView.layer.shadowRadius = 7
        let path = UIBezierPath(rect: self.cardView.bounds)
        self.cardView.layer.shadowPath = path.cgPath
        self.cardView.layer.shadowOpacity = 0.2
    }
    
    
    func showProfile() {
        Segues.showProfile(user: user, navigationController: parentVC.navigationController!)

    }

    
    
    
    @IBAction func commentButtonTapped(_ sender: Any) {
            Segues.goToPopoverComments(post: cellPost, selfParentVC: parentVC, tabBarC: parentVC.tabBarController as! TabBarController)
        
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        let actionSheetInstance: ActionSheet = ActionSheet(post: cellPost, vc: parentVC)
        actionSheetInstance.openMoreOptions()

        
//        if let homeVC = parentVC as? HomeVC {
////            homeVC.openMoreOptions(cellPost)
//        } else if let profileVC = parentVC as? ProfileVC {
//            profileVC.openMoreOptions(cellPost)
//        } else if let _ = parentVC as? HashTagVC {
//            let actionSheetInstance: ActionSheet = ActionSheet(vc: parentVC)
//            actionSheetInstance.openMoreOptions(post: cellPost)
//
//        }
    }
    
    
}







