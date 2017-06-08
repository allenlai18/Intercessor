//
//  GroupMessage.swift
//  Intercessor
//
//  Created by Allen Lai on 9/15/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class GroupMessage: SuperMessage {
    var GMID: String!
    var groupID: String
    var groupPicURL: String
    var users: [String]
    
    
    // not saved to firebase
    var currUsers: [User]!
    var messagesRef: FIRDatabaseReference!
    
    init(group: Group) {
        self.groupID = group.groupID
        self.groupPicURL = group.groupPicURL
        self.users = group.users


        super.init(otherUserNameOrGroupName: group.name)
    }
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as! [String: AnyObject]
        self.GMID = dict["GMID"] as? String ?? ""
        self.groupID = dict["groupID"] as? String ?? ""
        let groupName = dict["groupName"] as? String ?? ""
        self.groupPicURL = dict["groupPicURL"] as? String ?? ""
        
        self.users = [String]()
        let usersDict = dict["usersDict"] as? [String: AnyObject] ?? [String: AnyObject]()
        
        for (userID, _) in usersDict {
            self.users.append(userID)
        }
        super.init(otherUserNameOrGroupName: groupName)
        let dateFormat = dict["timeStamp"] as? Double ?? 0
        self.timeStamp =  Date(timeIntervalSince1970: dateFormat)
        self.messages = [Message]()
        
        self.messagesRef = Helper.groupMessagesRef.child(self.GMID).child("messages")
        messagesRef.observe(.childAdded, with: { (snapshot) in
            let newMessage = Message(snapshot: snapshot)
            self.messages.append(newMessage)
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: self.GMID), object: nil, userInfo: ["newMessage" : newMessage])
        })
    }
    func saveNewGroupMessage() -> String {
        let ref = Helper.groupMessagesRef.childByAutoId()
        self.GMID = ref.key
        self.messagesRef = Helper.groupMessagesRef.child(self.GMID).child("messages")
        ref.setValue(toAnyObject())
        for userID in self.users {
            Helper.groupMessagesRef.child(self.GMID).child("users").child(userID).setValue(true)
        }
        return ref.key
    }

    func toAnyObject() -> [String: Any] {
        return [
            "GMID" : GMID,
            "groupName" : otherUserNameOrGroupName,
            "groupPicURL" : groupPicURL,
            "groupID" : groupID,
            "timeStamp": timeStamp.timeIntervalSince1970
        ]
    }
    func sendNewMessage(_ message: Message) {
        let newMessageRef = self.messagesRef.childByAutoId()
        if let prevMessageDate = self.messages?.last?.date {
            let hours = message.date.hours(from: prevMessageDate)
            if hours > 3 {
                message.needTimeStampInChat = true
            }
        } else {
            message.needTimeStampInChat = true
        }
        updateTimeStamp()
        newMessageRef.setValue(message.toAnyObject())
        
    }

    func updateTimeStamp() {
        self.timeStamp = Date()
        self.messagesRef.child("timeStamp").setValue(self.timeStamp.timeIntervalSince1970)
    }

}





