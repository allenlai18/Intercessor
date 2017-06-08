//
//  NotificationTableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 9/18/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var notificationMessageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    var parentVC: NotificationsVC!

    var notification: Notification! {
        didSet {
            if self.notification.subject != nil {
                self.profileImageView.loadImageUsingCacheWithUrlString(self.notification.subject.profilePicURL)
            }
            
            self.timeAgoLabel.text = dateTimeFormattedAsTimeAgo(self.notification.date)
            self.notificationMessageLabel.text = notification.toNotificationMessage()

            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // make profileImage rounded
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
        Segues.showProfile(user: notification.subject, navigationController: parentVC.navigationController!)
    }
    
    override func prepareForReuse() {
        profileImageView.image = nil
        
        
        
    }
    
}
