//
//  TableViewCell.swift
//  Intercessor
//
//  Created by Allen Lai on 8/22/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit


class MessagesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeDetailLabel: UILabel!
    @IBOutlet weak var blueDotImageView: UIImageView!
    
    
    // only being set before
    var chatMessage: SuperMessage! {
        didSet {
            
            if let directMessage = chatMessage as? DirectMessage {
                // fetch the friend data
                let friendID = directMessage.getOtherUserID()
                AllFriendsRepo.sharedInstance.fetchUser(userID: friendID) { (userFound) in
                    self.friend = userFound
                    self.setLastMessageDetails()

                }

                blueDotImageView.isHidden = true
                Helper.directMessagesRef.child(directMessage.DMID).child(UserRepo.currentUser.uid+"unread").observe(.value, with: { (snapshot) in
                    if snapshot.value as? Bool ?? true {
                        self.blueDotImageView.isHidden = false
                        self.setLastMessageDetails()
                    } else {
                        self.blueDotImageView.isHidden = true
                    }
                })

            } else {
                let groupMessage = chatMessage as! GroupMessage
                profileImageView.loadImageUsingCacheWithUrlString(groupMessage.groupPicURL)
                displayNameLabel.text = groupMessage.otherUserNameOrGroupName
                // TODO: set the blue dot unread thing
                setLastMessageDetails()

            }

        }
    }
    
    var friend: User! {
        didSet {
            profileImageView.loadImageUsingCacheWithUrlString(friend.profilePicURL)
            displayNameLabel.text = friend.displayName
        }
    }
    

    func setLastMessageDetails() {
        var detailText: String = "You are now friends with " + friend.displayName + ". Send a message!"
        if let lastMessage = chatMessage.messages.last {
            switch lastMessage.mediaType {
            case "TEXT":
                detailText = lastMessage.content
            case "PHOTO":
                if lastMessage.senderID == UserRepo.currentUser.uid {
                    detailText = "You sent a photo"
                } else {
                    detailText = "\(self.friend.displayName) sent a photo"
                }
            case "VIDEO":
                if lastMessage.senderID == UserRepo.currentUser.uid {
                    detailText = "You sent a video"
                } else {
                    detailText = "\(self.friend.displayName) sent a video"
                }
            default:
                print("unknown data type")
            }
            self.timeDetailLabel.text = dateTimeFormattedAsTimeAgo(lastMessage.date)
        }
        self.detailLabel.text = detailText     // set detail
        
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
        super.prepareForReuse()
        self.blueDotImageView.isHidden = true
        self.profileImageView.image = nil
        self.timeDetailLabel.text = nil
        self.detailLabel.text = ""
        
    }
    
}





