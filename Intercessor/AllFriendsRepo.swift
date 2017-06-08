//
//  AllFriendsRepo.swift
//  Intercessor
//
//  Created by Allen Lai on 9/21/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import FirebaseAuth


class AllFriendsRepo {
    
    static let sharedInstance = AllFriendsRepo()      // current user

    var allFriendDictCache: [String: User] = [String: User]()       // [friendID : UserObject]
    var currFriends: [User] = [User]()

    
    func addFriend(_ newFriend: User) {
        self.allFriendDictCache[newFriend.uid] = newFriend
        self.currFriends.append(newFriend)
    }
    
    func fetchAllFriendsData() {
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        Helper.usersRef.child(userID).child("friends").observe(.childAdded, with: { (snapshot) in
            let friendID: String = snapshot.key
            UserRepo.currentUser.friends.append(friendID)
            Helper.usersRef.child(friendID).observeSingleEvent(of: .value, with: { (userSnapshot) in
                if userSnapshot.exists() {
                    let newFriend = User(snapshot: userSnapshot)
                    // download profile image and save in cache
                    Helper.helper.downloadAndSaveProfileURL(newFriend.profilePicURL)
                    
                    self.addFriend(newFriend)
                    newFriend.fetchUserPostsAndForNewFeed()     // gets the users posts and news feed
                } else {
                    print("error in finding friend")
                }
            })
        })
    }
    
    func fetchFriendFromCache(_ uid: String) -> User? {
        // check cache for image first
        return self.allFriendDictCache[uid]
    }
    func fetchUser(userID: String, completion: @escaping (_ foundUser: User) -> Void) {
        if let friendUser = fetchFriendFromCache(userID) {
            completion(friendUser)
        } else {
            Helper.usersRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let userDownloaded = User(snapshotForBasicData: snapshot)
                    self.allFriendDictCache[userID] = userDownloaded
                    completion(userDownloaded)
                    
                } else {
                    print("error: cant find user")
                }
            })
        }
        
    }
    
}

