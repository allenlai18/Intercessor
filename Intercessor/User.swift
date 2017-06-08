//
//  User.swift
//  Intercessor
//
//  Created by Allen Lai on 8/28/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User {
    
    var uid: String
    var displayName: String
    var username: String
    var profilePicURL: String
    var bio: String
    var friends: [String]
    var friendRequestsSent: [String]
    var friendRequestsReceived: [String]
    var groups: [String]
    var posts: [String]
    var subscribers: [String]
    var verifiedStatus: Bool
    var oneSignalID: String!

    // private info
    var directMessages: [String]
    

    // fields for cache and not saved to FireBase
    var usersPosts = [Post]()
    var friendDirectMessageID: String! // the directMessageId with them

    
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as! [String: AnyObject]
        self.uid = dict["uid"] as? String ?? ""
        self.displayName = dict["displayName"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.profilePicURL = dict["profilePicURL"] as? String ?? ""
        self.bio = dict["bio"] as? String ?? ""
        self.verifiedStatus = dict["verifiedStatus"] as? Bool ?? false
        self.oneSignalID = dict["oneSignalID"] as? String ?? ""

        self.friends = [String]()
        self.friendRequestsSent = [String]()
        self.friendRequestsReceived = [String]()
        self.groups = [String]()
        self.posts = [String]()
        self.subscribers = [String]()
        self.directMessages = [String]()
        
        let friendsDict = dict["friends"] as? [String: AnyObject] ?? [String: AnyObject]()
        let postsDict = dict["posts"] as? [String: AnyObject] ?? [String: AnyObject]()
        
        let friendRequestSentDict = dict["friendRequestsSent"] as? [String: AnyObject] ?? [String: AnyObject]()
        let friendRequestsReceivedDict = dict["friendRequestsReceived"] as? [String: AnyObject] ?? [String: AnyObject]()
        let groupsDict = dict["groups"] as? [String: AnyObject] ?? [String: AnyObject]()
        let subscribersDict = dict["subscribers"] as? [String: AnyObject] ?? [String: AnyObject]()
        let directDict = dict["directMessages"] as? [String: AnyObject] ?? [String: AnyObject]()
        
        for (friendID, _) in friendsDict { self.friends.append(friendID) }
        for (postID, _) in postsDict { self.posts.append(postID) }
        
        for (friendID, _) in friendRequestSentDict { self.friendRequestsSent.append(friendID) }
        for (friendID, _) in friendRequestsReceivedDict { self.friendRequestsReceived.append(friendID) }
        for (groupID, _) in groupsDict { self.groups.append(groupID) }
        for (userID, _) in subscribersDict { self.subscribers.append(userID) }
        for (directID, _) in directDict { self.directMessages.append(directID) }

    }
    
    init(snapshotForBasicData: FIRDataSnapshot) {
        let dict = snapshotForBasicData.value as! [String: AnyObject]
        self.uid = dict["uid"] as? String ?? ""
        self.displayName = dict["displayName"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.profilePicURL = dict["profilePicURL"] as? String ?? ""
        self.bio = dict["bio"] as? String ?? ""
        self.oneSignalID = dict["oneSignalID"] as? String ?? ""

        self.friends = [String]()
        self.friendRequestsSent = [String]()
        self.friendRequestsReceived = [String]()
        self.groups = [String]()
        self.posts = [String]()
        self.subscribers = [String]()
        self.directMessages = [String]()
        self.verifiedStatus = dict["verifiedStatus"] as? Bool ?? false
        
        let friendsDict = dict["friends"] as? [String: AnyObject] ?? [String: AnyObject]()
        let postsDict = dict["posts"] as? [String: AnyObject] ?? [String: AnyObject]()
        for (friendID, _) in friendsDict { self.friends.append(friendID) }
        for (postID, _) in postsDict { self.posts.append(postID) }
    }
    
    init(selfUser: UserRepo) {
        self.uid = selfUser.uid
        self.displayName = selfUser.displayName
        self.username = selfUser.username
        self.profilePicURL = selfUser.profilePicURL
        self.bio = selfUser.bio
        self.friends = selfUser.friends
        self.friendRequestsSent = selfUser.friendRequestsSent
        self.friendRequestsReceived = selfUser.friendRequestsReceived
        self.groups = selfUser.groups
        self.posts = selfUser.posts
        self.subscribers = selfUser.subscribers
        self.verifiedStatus = selfUser.verifiedStatus
        self.directMessages = selfUser.directMessages
        self.oneSignalID = selfUser.oneSignalID
    }


    func fetchUserPostsAndForNewFeed() {
        Helper.usersRef.child(self.uid).child("posts").observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? Bool ?? false) {
                let postID: String = snapshot.key
                Helper.postsRef.child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let postFetched = Post(snapshot: snapshot)
                        if !(postFetched.privacy == .private) {
                            self.usersPosts.insert(postFetched, at: 0)
                            // add the post to newsfeed
                            UserRepo.currentUser.currNewsFeedPosts.append(postFetched)
                            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.NotificationNames.reloadMyFeed), object: nil)
                        }
                    } else {
                        print("error! in trying to find a specific post")
                    }
                })
            }
        })

    }
    
    


}


