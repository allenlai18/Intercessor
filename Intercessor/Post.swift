//
//  Post.swift
//  Intercessor
//
//  Created by Allen Lai on 8/28/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import FirebaseDatabase


class Post {
    enum PostPrivacy: Int {
        case `public` = 0
        case friendsOnly = 1
        case `private` = 2
    }
    enum PostType: Int {
        case prayer = 0
        case praise = 1
    }
    
    var postID: String!
    var userID: String
    var title: String
    var descrip: String
    var postType: PostType
    var privacy: PostPrivacy
    var date: Date
    var comments: [Comment]!
    var friendsToSend: [String]
    var groupsToSend: [String]
    
    var hashTags: [String]
    var mentions: [String]

    // not stored in FireBase
    var commentsRef: FIRDatabaseReference!

    var user: User!
    init(userID: String, title: String, descrip: String, postType: PostType, privacy: PostPrivacy, friendsToSend: [String], groupsToSend: [String]) {
        self.userID = userID
        self.title = title
        self.descrip = descrip
        self.postType = postType
        self.privacy = privacy
        self.friendsToSend = friendsToSend
        self.groupsToSend = groupsToSend
        self.hashTags = [String]()
        self.mentions = [String]()
        
        let words = self.descrip.components(separatedBy: " ")
        for word in words.filter({$0.hasPrefix("#")}) {
            let hashTagString = String(word.characters.dropFirst()).lowercased()
            if hashTagString.isValidHashTag {
                self.hashTags.append(hashTagString)
            }
        }
        for word in words.filter({$0.hasPrefix("@")}) {
            let mentionString = String(word.characters.dropFirst()).lowercased()
            if mentionString.isValidMention {
                self.mentions.append(mentionString)
            }
        }
        self.date = Date()
        self.comments = [Comment]()
        
    }
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as? [String: AnyObject] ?? [String: AnyObject]()
        self.postID = dict["postID"] as? String ?? ""
        self.userID = dict["userID"] as? String ?? ""
        self.title = dict["title"] as? String ?? ""
        self.descrip = dict["descrip"] as? String ?? ""
        self.postType = PostType(rawValue: dict["postType"]  as? PostType.RawValue ?? 0)!
        self.privacy = PostPrivacy(rawValue: dict["privacy"] as? PostPrivacy.RawValue ?? 0)!
        let dateFormat = dict["date"] as? Double ?? 0
        self.date =  Date(timeIntervalSince1970: dateFormat)
        self.friendsToSend =  dict["friendsToSend"] as? [String] ?? [String]()
        self.groupsToSend = dict["friendsToSend"] as? [String] ?? [String]()        // not yet used
        self.hashTags = dict["hashTags"] as? [String] ?? [String]()
        self.mentions = dict["mentions"] as? [String] ?? [String]()
        
        
        self.comments = [Comment]()
        let allCommentsDictionary = dict["comments"] as? [String: AnyObject] ?? [String: AnyObject]()
        for commentDict in allCommentsDictionary.values {
            self.comments.append(Comment(dict: commentDict as! [String : AnyObject]))
        }
        self.commentsRef = Helper.postsRef.child(self.postID).child("comments")
    }

    
    
    func saveNewPost() {
        let ref = Helper.postsRef.childByAutoId()
        self.postID = ref.key
        ref.setValue(toAnyObject())
        self.commentsRef = Helper.postsRef.child(self.postID).child("comments")
        // save to current posts field
        Helper.usersRef.child(UserRepo.currentUser.uid).child("posts").child(self.postID).setValue(true)
        
        sendToFriendsDMAndGroups()
        saveHashTagsToFireBase()
        
        // add a notification to all subscribers
//        for friendID in UserRepo.currentUser.subscribers {
//            let newPostnoti = Notification(ownerID: friendID, subjectID: UserRepo.currentUser.uid, action: .posted, object: .post, objectID: self.postID)
//            newPostnoti.saveNewNotification()
//        }

        // add all the friends and groups
//        for id in self.friendsToSend { ref.child("friendsToSend").child(id).setValue(true) }
//        for id in self.groupsToSend { ref.child("groupsToSend").child(id).setValue(true) }
        
    }
    func toAnyObject() -> [String: Any] {
        return [
            "postID" : postID,
            "userID" : userID,
            "title" : title,
            "descrip" : descrip,
            "privacy" : privacy.rawValue,
            "postType" : postType.rawValue,
            "date" : date.timeIntervalSince1970,
            "friendsToSend" : friendsToSend,
            "groupsToSend" : groupsToSend,
            "hashTags" : hashTags,
            "mentions" : descrip
        ]
    }
    func postComment(_ comment: Comment) {
        let newMessageRef = self.commentsRef.childByAutoId()
        newMessageRef.setValue(comment.toAnyObject())
        self.comments.append(comment)
        
        // add a notification
        if self.userID != UserRepo.currentUser.uid {
            let commentedOnPostNoti = Notification(ownerID: self.userID, subjectID: UserRepo.currentUser.uid, action: .commented, object: .post, objectID: self.postID)
            commentedOnPostNoti.saveNewNotification()
        }
    }
    
    func sendToFriendsDMAndGroups() {
        // send it to all friends, appending to all friends DM and groups
        var messageText: String = ""
        if self.postType == .prayer {
            messageText += "🙏: "
        } else {
            messageText += "🙌: "
        }
        messageText += self.title + " - " + self.descrip
        
        var messagePostType: Message.MessageType
        if self.postType == .prayer {
            messagePostType = .prayer
        } else {
            messagePostType = .praise
        }
        let postMessage = Message(mediaType: "TEXT", senderID: UserRepo.currentUser.uid, senderName: UserRepo.currentUser.displayName, content: messageText, messageType: messagePostType)
        for friendUID in self.friendsToSend {
            // send a notification
            let newDMNoti: Notification!
            if postType == .prayer {
                newDMNoti = Notification(ownerID: friendUID, subjectID: UserRepo.currentUser.uid, action: .sent, object: .prayerRequest, objectID: postID)
            } else {
                newDMNoti = Notification(ownerID: friendUID, subjectID: UserRepo.currentUser.uid, action: .sent, object: .praiseReport, objectID: postID)
            }
            newDMNoti.saveNewNotification()
            
            let directMessageID = Helper.helper.getDirectMessageID(UserRepo.currentUser.uid, userID2: friendUID)
            Helper.helper.sendDMToDirectmessageID(directMessageID, message: postMessage)
            
        }
        for groupID in self.groupsToSend {
            Helper.groupsRef.child(groupID).child("posts").child(self.postID).setValue(true)
        }
    }
    
    func saveHashTagsToFireBase() {
        for hashTagString in self.hashTags {
            Helper.hashTagsRef.child(hashTagString).child(self.postID).setValue(true)
        }
    }
    func findHashTagsAndMentions() {
        let words = self.descrip.components(separatedBy: " ")
        for word in words.filter({$0.hasPrefix("#")}) {
            let hashTagString = String(word.characters.dropFirst()).lowercased()
            if hashTagString.isValidHashTag {
                self.hashTags.append(hashTagString)
            }
        }
        for word in words.filter({$0.hasPrefix("@")}) {
            let mentionString = String(word.characters.dropFirst()).lowercased()
            if mentionString.isValidMention {
                self.mentions.append(mentionString)
            }
        }
    }
    func updatePost() {
        findHashTagsAndMentions()
        saveHashTagsToFireBase()
        Helper.postsRef.child(postID).setValue(toAnyObject())
    }
    
    func deletePostTemp() {
        // find the post and delete from currentPost
        var counter = 0
        for postInCurr in UserRepo.currentUser.currPosts {
            
            if postInCurr.postID == self.postID {
                Helper.usersRef.child(UserRepo.currentUser.uid).child("posts").child(self.postID).setValue(false)
                UserRepo.currentUser.currPosts.remove(at: counter)
                break
            }
            counter += 1
        }
        
        for groupID in groupsToSend {
            Helper.groupsRef.child(groupID).child("posts").child(self.postID).setValue(false)
        }
    }
    func deletePostPermanent() {
        var counter = 0
        for postInCurr in UserRepo.currentUser.currPosts {
            
            if postInCurr.postID == self.postID {
                Helper.usersRef.child(UserRepo.currentUser.uid).child("posts").child(self.postID).setValue(nil)
                Helper.postsRef.child(self.postID).setValue(nil)
                UserRepo.currentUser.currPosts.remove(at: counter)
                break
            }
            counter += 1
        }

        
        for groupID in groupsToSend {
            Helper.groupsRef.child(groupID).child("posts").child(self.postID).setValue(nil)
        }
        
    }
    
    func turnPostToMessage() -> String {
        var buffer = ""
        if self.user != nil {
            buffer += self.user.displayName + "'s "
        }
        
        if self.postType == .praise {
            buffer += "🙌 "
        } else {
            buffer += "🙏 "

        }
        buffer += self.title + " - "
        buffer += self.descrip
        
        buffer += "  shared from Intercessor app (https://appsto.re/us/BFLHeb.i)"
        return buffer
    }
}

class Comment {         // class for Post
    var userID: String
    var content: String
    var date: Date
    var groupID: String     // **** If the post is from a group, use "1" if individual post ****
    init(userID: String, content: String, groupID: String) {
        self.userID = userID
        self.content = content
        self.date = Date()
        self.groupID = groupID
    }
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as! [String: AnyObject]
        self.userID = dict["userID"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        let dateFormat = dict["date"] as! Double
        self.date =  Date(timeIntervalSince1970: dateFormat)
        self.groupID = dict["groupID"] as? String ?? ""
    }
    init(dict: [String: AnyObject]) {
        self.userID = dict["userID"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        let dateFormat = dict["date"] as! Double
        self.date =  Date(timeIntervalSince1970: dateFormat)
        self.groupID = dict["groupID"] as? String ?? ""
    }
    
    func toAnyObject() -> [String: Any] {
        return [
            "userID" : userID,
            "content" : content,
            "date" : date.timeIntervalSince1970,
            "groupID" : groupID
        ]
    }
}




