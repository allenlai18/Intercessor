//
//  UserRepository.swift
//  Intercessor
//
//  Created by Allen Lai on 8/30/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import LilithProgressHUD
import OneSignal


class UserRepo {
    
    // current user
    static var currentUser: UserRepo! 
        
    
    // all current users friends
    var allFriendsRepo: AllFriendsRepo = AllFriendsRepo.sharedInstance
    var currPosts = [Post]()
    var currMessages = [SuperMessage]()
    var currNotifications = [Notification]()
    var currNewsFeedPosts = [AnyObject]()
    
    var currGroups = [Group]()

    
    // notification badges number
    var numberOfNotificationsUnseen: Int! {
        didSet {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.NotificationNames.updateNotificationsBadge), object: nil)
        }
    }
    var numberOfMessagesUnseen: Int! {
        didSet {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.NotificationNames.updateMessagesBadge), object: nil)
        }
    }
    
    
    // fields saved to Firebase
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
    var directMessages: [String]
    var verifiedStatus: Bool
    var email: String!
    var oneSignalID: String!

    init(uid: String, displayName: String, profilePicURL: String) {
        self.uid = uid
        self.displayName = displayName
        self.username = ""
        self.profilePicURL = profilePicURL
        self.email = ""
        self.bio = ""
        self.friends = [String]()
        self.friendRequestsSent = [String]()
        self.friendRequestsReceived = [String]()
        self.groups = [String]()
        self.posts = [String]()
        self.subscribers = [String]()
        self.directMessages = [String]()
        self.verifiedStatus = false
    }
    init(snapshotForCurrentUser: FIRDataSnapshot) {
        let dict = snapshotForCurrentUser.value as? [String: AnyObject] ?? [String: AnyObject]()
        self.uid = dict["uid"] as? String ?? ""
        self.displayName = dict["displayName"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.profilePicURL = dict["profilePicURL"] as? String ?? ""
        self.bio = dict["bio"] as? String ?? ""
        self.verifiedStatus = dict["verifiedStatus"] as? Bool ?? false

        self.friends = [String]()
        self.friendRequestsSent = [String]()
        self.friendRequestsReceived = [String]()
        self.groups = [String]()
        self.posts = [String]()
        
        
        self.subscribers = [String]()
        self.directMessages = [String]()
        
    }
    
    func updateUserInfo() {
        Helper.usersRef.child(self.uid).child("uid").setValue(uid)
        Helper.usersRef.child(self.uid).child("displayName").setValue(displayName)
        Helper.usersRef.child(self.uid).child("username").setValue(username)
        Helper.usersRef.child(self.uid).child("profilePicURL").setValue(profilePicURL)
        Helper.usersRef.child(self.uid).child("bio").setValue(bio)
        Helper.usersRef.child(self.uid).child("verifiedStatus").setValue(verifiedStatus)
        Helper.usersRef.child(self.uid).child("oneSignalID").setValue(oneSignalID)
    }
    
    func saveNewUser() {
        Helper.usersRef.child(self.uid).setValue(toAnyObject())
        OneSignal.idsAvailable { (userID, pushToken) in
            if pushToken != nil {
                UserRepo.currentUser.oneSignalID = userID
                UserRepo.currentUser.updateUserInfo()
            }
        }
        
        let newDM = DirectMessage(firstUser: UserRepo.currentUser.uid, otherUser: "optXrzpdqrNLE5PWrM6PIsplDan1")
        newDM.defaultDMFromAllensPhone()
        
        FriendAction.addToFriends(friendID: "optXrzpdqrNLE5PWrM6PIsplDan1")
        let newMessage = Message(mediaType: "TEXT", senderID: "optXrzpdqrNLE5PWrM6PIsplDan1", senderName: "Allen Lai", content: "Hello!", messageType: .none)
        newDM.sendNewMessage(newMessage)

        // create a username:uid under "username"
        Helper.usernamesRef.child(self.username).setValue(forUserNamesBranch())
    }
    func toAnyObject() -> [String: Any] {
        return [
            "uid" : uid,
            "displayName" : displayName,
            "username" : username,
            "profilePicURL" : profilePicURL,
            "bio" : bio,
            "verifiedStatus" : verifiedStatus
//            "oneSignalID" : oneSignalID
        ]
    }
    
    func forUserNamesBranch() -> [String: Any] {
        return [
            "displayName": self.displayName,
            "uid": self.uid,
            "email": self.email
        ]
    }

    
    // loading data functions
    // load Current UserBasicData
    static func fetchCurrentUserBasicData() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).observeSingleEvent(of: .value, with: { (userSnapshot) in
            if userSnapshot.exists() {
                UserRepo.currentUser = UserRepo(snapshotForCurrentUser: userSnapshot)
                
                
                // fetch all friends
                UserRepo.currentUser.allFriendsRepo.fetchAllFriendsData()

                
                UserRepo.findNumberOfUnreadMessages()
                
                UserRepo.fetchObserveFriendRequestSent()
                UserRepo.fetchObserveFriendRequestReceived()
                
                // download profile image and save in cache
                Helper.helper.downloadAndSaveProfileURL(UserRepo.currentUser.profilePicURL)
                
                OneSignal.idsAvailable { (userID, pushToken) in
                    if pushToken != nil {
                        UserRepo.currentUser.oneSignalID = userID
                        UserRepo.currentUser.updateUserInfo()
                    }
                }
                
            } else {
                // user does not exits move them to signup and log them out
                Helper.helper.switchToSignUpLogin()
                LilithProgressHUD.hide()
                do {
                    try FIRAuth.auth()?.signOut()
//                    print(FIRAuth.auth()?.currentUser)
                } catch let error {
                    print(error)
                }
            }

        }){ (error) in
            print(error.localizedDescription)
        }
        
    }
    
    static func fetchObserveAllUsersPosts() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("posts").observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? Bool ?? false) {
                let postID: String = snapshot.key
                UserRepo.currentUser.posts.append(postID)
                Helper.postsRef.child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        UserRepo.currentUser.currPosts.insert(Post(snapshot: snapshot), at: 0)
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "loadPosts"), object: nil)
                    }
                })
            }
        })
    }
    
    // fetch the direct message instance and put it in currDM and put it in friends User field friendDirectMessageID
    static func fetchObserveAllMessagesData() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("directMessages").observe(.childAdded, with: { (snapshot) in
            let messageID: String = snapshot.key
            UserRepo.currentUser.directMessages.append(messageID)
            Helper.directMessagesRef.child(messageID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let fetchedDM: DirectMessage = DirectMessage(snapshotWithMessages: snapshot)
                    
                    UserRepo.currentUser.currMessages.insert(fetchedDM, at: 0)
                    // find the friend user and store the DMID to the user
                    let friendID : String = fetchedDM.getOtherUserID()
                    
                    if let friend: User = UserRepo.currentUser.allFriendsRepo.allFriendDictCache[friendID] {
                        friend.friendDirectMessageID = fetchedDM.DMID
                    }   // else maybe fetch the user from Firebase???
                    
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kLoadCurrentUserMessages), object: nil)
                }
            })
            
        })
    }
    
    static func findNumberOfUnreadMessages() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        var unreadCount: Int = 0
        Helper.usersRef.child(userID).child("directMessages").observe(.value, with: { (snapshot) in
            let messageID: String = snapshot.key

            Helper.directMessagesRef.child(messageID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    if snapshot.childSnapshot(forPath: UserRepo.currentUser.uid+"unread").value as? Bool ?? true {
                        unreadCount += 1
                        UserRepo.currentUser.numberOfMessagesUnseen = unreadCount
                    }
                    
                }
            })
            
        })

        
    }
    

    static func fetchAllNotificationsData() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("notifications").observe(.childAdded, with: { (snapshot) in
            // check if value actually exists there
            if snapshot.exists() {
                let newNotification = Notification(snapshot: snapshot)
                UserRepo.currentUser.currNotifications.insert(newNotification, at: 0)
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kLoadCurrentUserNotifications), object: nil)
            } else {
                print("notification snapshot does not exists!")
            }
        })
    }
    
    
    // MARK: functions to fetch friendRequests
    static func fetchObserveFriendRequestSent() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("friendRequestsSent").observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? Bool ?? false) {
                let userID: String = snapshot.key
                UserRepo.currentUser.friendRequestsSent.append(userID)
            }
        })
    }
    
    static func fetchObserveFriendRequestReceived() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("friendRequestsReceived").observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? Bool ?? false) {
                let userID: String = snapshot.key
                UserRepo.currentUser.friendRequestsReceived.append(userID)
            }
        })
    }
}










