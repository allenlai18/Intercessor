//
//  Group.swift
//  Intercessor
//
//  Created by Allen Lai on 8/28/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class Group {
    var groupID: String!
    var name: String
    var groupPicURL: String
    var users: [String]
    var posts: [String]
    
    var groupMessagesID: String!
    
    var currPostsInGroup: [Post]!
    
    init(name: String, users: [String]) {
        self.name = name
        self.groupPicURL = ""
        self.users = users
        self.posts = [String]()
        self.currPostsInGroup = [Post]()
    }
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as? [String: AnyObject] ?? [String: AnyObject]()
        self.groupID = dict["groupID"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.groupPicURL = dict["groupPicURL"] as? String ?? ""
        
        self.users = [String]()
        self.posts = [String]()

        let usersDict = dict["users"] as? [String: AnyObject] ?? [String: AnyObject]()
        let postsDict = dict["posts"] as? [String: AnyObject] ?? [String: AnyObject]()

        for (userID, _) in usersDict {
            self.users.append(userID)
        }
        for (postID, _) in postsDict {
            self.posts.append(postID)
        }
        
        self.groupMessagesID = dict["groupMessagesID"] as? String ?? ""
        self.currPostsInGroup = [Post]()

    }
    func toAnyObject() -> [String: Any] {
        return [
            "groupID" : groupID,
            "name" : name,
            "groupPicURL" : groupPicURL,
            "groupMessagesID" : groupMessagesID
        ]
    }
    func saveNewGroup(_ groupImage: UIImage?) {
        let groupRef: FIRDatabaseReference = Helper.groupsRef.childByAutoId()
        self.groupID = groupRef.key
        // save the group image
        let filePath = "\(groupRef.key)/\(Date.timeIntervalSinceReferenceDate)"
        if let groupPic = groupImage {
            let data = UIImageJPEGRepresentation(groupPic, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
                in
                if error != nil {
                    
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                self.groupPicURL = fileUrl
                

                self.saveGroupMessageAndAtUsers(groupRef: groupRef)
            }
            
        } else {
            self.saveGroupMessageAndAtUsers(groupRef: groupRef)
        }

        
    }
    func saveGroupMessageAndAtUsers(groupRef: FIRDatabaseReference) {
        // create groupMessage instance
        let groupsMessage: GroupMessage = GroupMessage(group: self)
        self.groupMessagesID = groupsMessage.saveNewGroupMessage()
        
        groupRef.setValue(self.toAnyObject())    // save the whole group
        // save the groupID every member
        for friendID in self.users {
            Helper.usersRef.child(friendID).child("groups").child(self.groupID).setValue(true)
        }
        for userID in self.users {
            groupRef.child("users").child(userID).setValue(true)
        }
    }
    
    
    

}




