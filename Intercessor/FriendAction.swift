//
//  FriendAction.swift
//  Intercessor
//
//  Created by Allen Lai on 11/18/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation


open class FriendAction {
    
    static func sendFriendRequest(userID: String) {
        if userID == UserRepo.currentUser.uid {
            return
        }
        // check if the user is already sent a friend request, if so just add as friend
        for friendID in UserRepo.currentUser.friendRequestsReceived {
            if friendID == UserRepo.currentUser.uid {
                FriendAction.addToFriends(friendID: userID)
                return
            }
        }
        // Send the friend Request and notification
        Helper.usersRef.child(UserRepo.currentUser.uid).child("friendRequestsSent").child(userID).setValue(true)
        Helper.usersRef.child(userID).child("friendRequestsReceived").child(UserRepo.currentUser.uid).setValue(true)
        
        let sentFriendRequestNoti = Notification(ownerID: userID, subjectID: UserRepo.currentUser.uid, action: .sent, object: .friendRequest, objectID: userID)
        sentFriendRequestNoti.saveNewNotification()
    }
    static func addToFriends(friendID: String) {
        if friendID == UserRepo.currentUser.uid {
            return
        }
        // add friends to both people
        Helper.usersRef.child(UserRepo.currentUser.uid).child("friends").child(friendID).setValue(true)
        Helper.usersRef.child(friendID).child("friends").child(UserRepo.currentUser.uid).setValue(true)
        
        // delete in friendRequestsSent and friendRequestsReceived
        Helper.usersRef.child(UserRepo.currentUser.uid).child("friendRequestsReceived").child(friendID).setValue(nil)
        Helper.usersRef.child(UserRepo.currentUser.uid).child("friendRequestsSent").child(friendID).setValue(nil)
        Helper.usersRef.child(friendID).child("friendRequestsReceived").child(UserRepo.currentUser.uid).setValue(nil)
        Helper.usersRef.child(friendID).child("friendRequestsSent").child(UserRepo.currentUser.uid).setValue(nil)
        
        // start a direct chat with them
        let newDirectMessage = DirectMessage(firstUser: UserRepo.currentUser.uid, otherUser: friendID)
        newDirectMessage.saveNewDirectMessage()
        
        // notification
        let acceptedFriendRequestNoti = Notification(ownerID: friendID, subjectID: UserRepo.currentUser.uid, action: .accepted, object: .friendRequest, objectID: friendID)
        acceptedFriendRequestNoti.saveNewNotification()
    }

    static func findMutualFriends(otherUser: User) -> [String] {
        var mutualFriends: [String] = []
        for friendID in UserRepo.currentUser.friends {
            if otherUser.friends.contains(friendID) {
                mutualFriends.append(friendID)
            }
        }
        return mutualFriends
    }
    
    
    
    
}





