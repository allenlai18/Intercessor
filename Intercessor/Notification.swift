//
//  Notification.swift
//  Intercessor
//
//  Created by Allen Lai on 9/15/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage

class Notification {

    enum NotificationAction: Int {
        case commented = 0
        case sent = 1
        case posted = 2
        case messaged = 3
        case accepted = 4
        case joined = 5

    }
    enum NotificationObject: Int {
        case post = 0
        case directMessage = 1
        case groupMessage = 2
        case group = 3
        case friendRequest = 4
        case prayerRequest = 5
        case praiseReport = 6
    }
    
    var notificationID: String!
    var ownerID: String     // owner of notification
    var subjectID: String   // the person doing the action
   
    var action: NotificationAction
    var object: NotificationObject
    var objectID: String!
    var date: Date
    var seen: Bool
    //not stored in FireBase
    var userNotificationRef: FIRDatabaseReference!  // the owners notification reference
    var subject: User!
    var objectInstance: AnyObject?

    init(ownerID: String, subjectID: String, action: NotificationAction, object: NotificationObject, objectID: String!) {
        self.ownerID = ownerID
        self.subjectID = subjectID
        self.action = action
        self.object = object
        self.objectID = objectID
        self.date = Date()
        self.seen = false
        // not stored to firebase

        self.userNotificationRef = Helper.usersRef.child(self.ownerID).child("notifications")
    }
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as! [String: AnyObject]
        self.notificationID = dict["notificationID"] as? String ?? ""
        self.ownerID = dict["ownerID"] as? String ?? ""
        self.subjectID = dict["subjectID"] as? String ?? ""
        self.action = NotificationAction(rawValue: dict["action"]  as? NotificationAction.RawValue ?? 0)!
        self.object = NotificationObject(rawValue: dict["object"] as? NotificationObject.RawValue ?? 0)!
        self.objectID = dict["objectID"] as? String ?? ""
        let dateFormat = dict["date"] as! Double
        self.date =  Date(timeIntervalSince1970: dateFormat)
        self.seen = dict["seen"] as? Bool ?? false
        self.userNotificationRef = Helper.usersRef.child(self.ownerID).child("notifications")
        // init the subject
        if let sub = UserRepo.currentUser.allFriendsRepo.fetchFriendFromCache(self.subjectID) {
            self.subject = sub
        } else {
            Helper.usersRef.child(self.subjectID).observeSingleEvent(of: .value, with: { (userSnapshot) in
                if userSnapshot.exists() {
                    self.subject = User(snapshot: userSnapshot)
                }
            })
        }
        // init the object
        if self.object == .group {
            Helper.groupsRef.child(self.objectID).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.objectInstance = snapshot.value as! String as AnyObject?
                }
            })
        } else if (self.object == .post) {
            Helper.postsRef.child(objectID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.objectInstance = Post(snapshot: snapshot)
                }
            })
        }
    }
    func saveNewNotification() {
        let ref = self.userNotificationRef.childByAutoId()
        self.notificationID = ref.key
        ref.setValue(toAnyObject())
        AllFriendsRepo.sharedInstance.fetchUser(userID: ownerID) { (userFound: User) in
            Push.SendPushNotification(message: self.toNotificationMessage(), userIds: [userFound.oneSignalID])
        }
        
    }

    func toAnyObject() -> [String: Any] {
        return [
            "notificationID" : notificationID,
            "ownerID" : ownerID,
            "subjectID" : subjectID,
            "action" : action.rawValue,
            "object" : object.rawValue,
            "objectID" : objectID,
            "date" : date.timeIntervalSince1970,
            "seen" : seen
        ]
    }
    func toNotificationMessage() -> String {
        var notificationMessage: String = ""

        if self.subject == nil {
            notificationMessage = "user does not exist"
        } else {
            notificationMessage = self.subject.displayName
        }
 
        
        switch self.action {
        case .commented:
            if self.object == .post {
                notificationMessage += " commented on your post..."
                
            } else if self.object == .group {
                notificationMessage += " commented in a group....."
            }
        case .sent:
            if self.object == .friendRequest {
                notificationMessage += " sent a friend request!"
            } else if self.object == .directMessage {
                notificationMessage += " sent a direct message!"
            } else if self.object == .prayerRequest {
                notificationMessage += " sent a prayer request!"
            } else if self.object == .praiseReport {
                notificationMessage += " sent a praise report!"
            }
            
        case .posted:
            if self.object == .post {
                notificationMessage += " posted a new post about ..."
            } else if self.object == .group {
                notificationMessage += " posted a new post in a group ..."
            }
        case .messaged:
            if self.object == .group {
                notificationMessage += " messaged group..."
            }
        case .accepted:
            if self.object == .friendRequest {
                notificationMessage += " accepted your friend request."
            }
        case .joined:
            if self.object == .group {
                if self.objectInstance != nil {
                    notificationMessage += " just joined a new group - " + (self.objectInstance as! String)
                } else {
                    notificationMessage += " just joined a new group"
                }
            }
            
        }
        return notificationMessage
    }
    
    func deleteNotificationOnFireBase() {
        self.userNotificationRef.child(self.notificationID).setValue(nil)
    }
    
/*
 
 All possible Cases:
     1.  [User] commented on your [Post]
     - [User] -> subjectID  - diplayName
     -  "commented" -> NotificationAction = 0
     - [Post] -> NotificationObject = 0
 
     2. [User] posted a new [Post]
     - [User] -> subjectID  - diplayName
     -  "post" -> NotificationAction = 2
     - [Post] -> NotificationObject = 0

     3. [User] sent you a message
     - [User] -> subjectID  - diplayName
     - "sent" -> NotificationAction = 1
     - "message" -> NotificationObject = 1
     
     5. [User] accepted your friend request
     - [User] -> subjectID  - diplayName
     - "accepted" -> NotificationAction = 4
     - "friend request" -> NotificationObject = 5

     6. [User] sent you a friend request
     - [User] -> subjectID  - diplayName
     - "sent" -> NotificationAction = 1
     - "friend request" -> NotificationObject = 5
     
     **7. [User] posted {[post]} in [group]
     - [User] -> subjectID  - diplayName
     - "posted" -> NotificationAction = 2
     - [group] -> NotificationObject = 4
     
     
     8. New [User] joined [Group]
     - [User] -> subjectID  - diplayName
     - "joined" -> NotificationAction = 5
     - [group] -> NotificationObject = 4
     
     **9. [User] commented on [post] in [Group]
     - [User] -> subjectID  - diplayName
     - "commented" -> NotificationAction = 0
     - [group] -> NotificationObject = 4
     
     10. [User] messaged [Group]
     - [User] -> subjectID  - diplayName
     - "messaged" -> NotificationAction = 3
     - [group] -> NotificationObject = 4
     
     
*/
    
    
}













