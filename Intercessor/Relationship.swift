//
//  Relationship.swift
//  Intercessor
//
//  Created by Allen Lai on 11/20/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation


enum RelationshipType: Int {
    case friends = 0
    case friendRequestSent = 1
    case friendRequestReceived = 2
    case notFriends = 3
    
}

open class Relationship {

    static func findRelationshipWithUser(userID: String) -> RelationshipType {
        if UserRepo.currentUser.friends.contains(userID) {
            return .friends
        } else if UserRepo.currentUser.friendRequestsSent.contains(userID) {
            return .friendRequestSent
        } else if UserRepo.currentUser.friendRequestsReceived.contains(userID) {
            return .friendRequestReceived
        } else {
            return .notFriends
        }
        
    }



}




