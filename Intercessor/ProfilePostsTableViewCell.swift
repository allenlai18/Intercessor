//
//  ProfilePostsTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/24/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import ActiveLabel

class ProfilePostsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!

    var cellPost: Post! {
        didSet {
            var title: String = ""
            switch self.cellPost.privacy {
            case .public:
                title += "🌐"
            case .friendsOnly:
                title += "👥"
            case .private:
                title += "🔒"
            }
            
            switch self.cellPost.postType {
            case .prayer:
                title += "🙏: "
            case .praise:
                title += "🙌: "
            }

            self.titleLabel.text = title + self.cellPost.title
            self.descriptionLabel.text = self.cellPost.descrip
            self.dateTimeLabel.text = dateTimeFormattedAsTimeAgo(self.cellPost.date)
            if self.cellPost.comments.count == 1 {
                self.numberOfCommentsLabel.text = "1 comment"
            } else {
                self.numberOfCommentsLabel.text = String(self.cellPost.comments.count) + " comments"
            }
        }
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        descriptionLabel.numberOfLines = 0
//        descriptionLabel.enabledTypes = [.hashtag]
//        descriptionLabel.text = "This is a post with #hashtags and a @userhandle."
//        descriptionLabel.textColor = .black
//        descriptionLabel.handleHashtagTap { hashtag in
//            print("Success. You just tapped the \(hashtag) hashtag")
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
