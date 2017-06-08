//
//  SuperMessage.swift
//  Intercessor
//
//  Created by Allen Lai on 10/19/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation




class SuperMessage {
    
    var otherUserNameOrGroupName: String! // other persons name or groupName
    var messageID: String!      // groupId or messageID
    var messages: [Message]!    // all messages
    
    var timeStamp: Date!
    
    
    init (otherUserNameOrGroupName: String) {
        self.otherUserNameOrGroupName = otherUserNameOrGroupName
        self.timeStamp = Date()
    }
    

    init() {
        self.timeStamp = Date()
    }
    
}



