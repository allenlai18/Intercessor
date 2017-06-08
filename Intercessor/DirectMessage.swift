//
//  DirectMessage.swift
//  Intercessor
//
//  Created by Allen Lai on 9/13/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DirectMessage: SuperMessage {
    var DMID: String!
    var firstUser: String       // creater of the Directmessage
    var secondUser: String
    
    // not saved to FireBase
    var messagesRef: FIRDatabaseReference!
    var otherUser: String!
    
    
    init(firstUser: String, otherUser: String) {
        self.firstUser = firstUser
        self.secondUser = otherUser
        self.otherUser = otherUser
        super.init(otherUserNameOrGroupName: self.otherUser)
        self.messages = [Message]()
    }

    init(snapshotWithMessages: FIRDataSnapshot) {
        let dict = snapshotWithMessages.value as! [String: AnyObject]
        self.DMID = dict["DMID"] as? String ?? ""
        self.firstUser = dict["firstUser"] as? String ?? ""
        self.secondUser = dict["secondUser"] as? String ?? ""

        super.init()
        self.otherUserNameOrGroupName = self.getOtherUserID()
        let dateFormat = dict["timeStamp"] as? Double ?? 0
        self.timeStamp =  Date(timeIntervalSince1970: dateFormat)
        
        self.messageID = self.DMID
        self.messages = [Message]()
        self.messagesRef = Helper.directMessagesRef.child(self.DMID).child("messages")
        messagesRef.observe(.childAdded, with: { (snapshot) in
            let newMessage = Message(snapshot: snapshot)
            self.messages.append(newMessage)
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: self.DMID), object: nil, userInfo: ["newMessage" : newMessage])
            
        })
    }
    
    func saveNewDirectMessage() {
        let ref = Helper.directMessagesRef.child(Helper.helper.getDirectMessageID(firstUser, userID2: secondUser))
        self.DMID = ref.key
        self.messagesRef = Helper.directMessagesRef.child(self.DMID).child("messages")
        ref.setValue(toAnyObject())
        
        Helper.usersRef.child(self.firstUser).child("directMessages").child(self.DMID).setValue(true)
        Helper.usersRef.child(self.secondUser).child("directMessages").child(self.DMID).setValue(true)
        
        // add a notification
//        let newMessageNoti = Notification(ownerID: getOtherUserID(), subjectID: UserRepo.currentUser.uid, action: .sent, object: .directMessage, objectID: self.DMID)
//        newMessageNoti.saveNewNotification()

    }
    
    
    func defaultDMFromAllensPhone() {
        let ref = Helper.directMessagesRef.child(Helper.helper.getDirectMessageID(firstUser, userID2: secondUser))
        self.DMID = ref.key
        self.messagesRef = Helper.directMessagesRef.child(self.DMID).child("messages")
        ref.setValue(toAnyObject())
        
        Helper.usersRef.child(self.firstUser).child("directMessages").child(self.DMID).setValue(true)
        Helper.usersRef.child(self.secondUser).child("directMessages").child(self.DMID).setValue(true)
        
        // add a notification
        let newMessageNoti = Notification(ownerID: UserRepo.currentUser.uid, subjectID: getOtherUserID(), action: .sent, object: .directMessage, objectID: UserRepo.currentUser.uid)
        newMessageNoti.saveNewNotification()
    }
    
    func toAnyObject() -> [String: Any] {
        return [
            "DMID" : DMID,
            "firstUser" : firstUser,
            "secondUser" : secondUser,
            "timeStamp": timeStamp.timeIntervalSince1970,
        ]
    }
    func sendNewMessage(_ message: Message) {
        let newMessageRef = self.messagesRef.childByAutoId()
        
        if let prevMessageDate = self.messages.last?.date {
            let hours = message.date.hours(from: prevMessageDate)
            if hours > 2 {
                message.needTimeStampInChat = true
            }
        } else {
            message.needTimeStampInChat = true      // first message needs a timeStamp
        }
        updateTimeStamp()
        newMessageRef.setValue(message.toAnyObject())

        // set otherUserUnread to true
        Helper.directMessagesRef.child(self.DMID).child(getOtherUserID()+"unread").setValue(true)
        
        // push notifications
        var pushMessage = UserRepo.currentUser.displayName + ":  "
        switch message.messageType {
        case .none:
            pushMessage += "sent you a direct message"
            AllFriendsRepo.sharedInstance.fetchUser(userID: getOtherUserID()) { (userFound: User) in
                Push.SendPushNotification(message: pushMessage, userIds: [userFound.oneSignalID])
            }
        case .praise:
            pushMessage += "sent you a praise report"
            // notification
            let newMessageNoti = Notification(ownerID: self.otherUser, subjectID: UserRepo.currentUser.uid, action: .sent, object: .praiseReport, objectID: self.DMID)
            newMessageNoti.saveNewNotification()
        case .prayer:
            pushMessage += "sent you a prayer request"
            // notification
            let newMessageNoti = Notification(ownerID: self.otherUser, subjectID: UserRepo.currentUser.uid, action: .sent, object: .prayerRequest, objectID: self.DMID)
            newMessageNoti.saveNewNotification()
        }

        
    }
    
    func getOtherUserID() -> String {
        if let user = self.otherUser {
            return user
        }
        if self.firstUser == UserRepo.currentUser.uid {
            self.otherUser = self.secondUser
        } else {
            self.otherUser = self.firstUser
        }
        return self.otherUser
    }
    
    func updateTimeStamp() {
        self.timeStamp = Date()
        Helper.directMessagesRef.child(DMID).child("timeStamp").setValue(self.timeStamp.timeIntervalSince1970)
//        self.messagesRef.child("timeStamp").setValue(self.timeStamp.timeIntervalSince1970)
    }
    
}








