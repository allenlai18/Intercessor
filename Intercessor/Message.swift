//
//  Message.swift
//  Intercessor
//
//  Created by Allen Lai on 9/14/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import JSQMessagesViewController



// class for DirectMessage, for my convenience
class Message {
    
    enum MessageType: Int {
        case none = 0
        case prayer = 1
        case praise = 2
    }
    
    var mediaType: String
    var senderID: String
    var senderName: String
    var content: String
    var date: Date
    var messageType: MessageType
    var needTimeStampInChat: Bool
    
    init(mediaType: String, senderID: String, senderName: String, content: String, messageType: MessageType) {
        self.mediaType = mediaType
        self.senderID = senderID
        self.senderName = senderName
        self.content = content
        self.date = Date()
        self.messageType = messageType
        self.needTimeStampInChat = false
    }
    init(snapshot: FIRDataSnapshot) {
        let dict = snapshot.value as! [String: AnyObject]
        self.mediaType = dict["mediaType"] as? String ?? ""
        self.senderID = dict["senderID"] as? String ?? ""
        self.senderName = dict["senderName"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        let dateFormat = dict["date"] as! Double

        self.date =  Date(timeIntervalSince1970: dateFormat)
        self.messageType = MessageType(rawValue: dict["messageType"] as? MessageType.RawValue ?? 0)!
        self.needTimeStampInChat = dict["needTimeStampInChat"] as? Bool ?? false
        
    }

    func toAnyObject() -> [String: Any] {
        return [
            "mediaType" : mediaType,
            "senderID" : senderID,
            "senderName" : senderName,
            "content" : content,
            "date": date.timeIntervalSince1970,
            "messageType" : messageType.rawValue,
            "needTimeStampInChat" : needTimeStampInChat
        ]
    }
    func toJSQMessage() -> JSQMessage {
        switch self.mediaType {
        case "TEXT":
            return JSQMessage(senderId: self.senderID, displayName: self.senderName, text: self.content)
        case "PHOTO":
            let data = try? Data(contentsOf: URL(string: self.content)!)
            let picture = UIImage(data: data!)
            let photo = JSQPhotoMediaItem(image: picture)
            if UserRepo.currentUser.uid == self.senderID {
                photo?.appliesMediaViewMaskAsOutgoing = true
            } else {
                photo?.appliesMediaViewMaskAsOutgoing = false
            }
            return JSQMessage(senderId: self.senderID, displayName: self.senderName, media: photo)

        case "VIDEO":
            let video = URL(string: self.content)!
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            if UserRepo.currentUser.uid == self.senderID {
                videoItem?.appliesMediaViewMaskAsOutgoing = true
            } else {
                videoItem?.appliesMediaViewMaskAsOutgoing = false
            }
            return JSQMessage(senderId: self.senderID, displayName: self.senderName, media: videoItem)
        default:
            print("unknown data type")
        }
        print("error in toJSQMessage")
        return JSQMessage(senderId: self.senderID, displayName: self.senderName, text: self.content)
    }
}
