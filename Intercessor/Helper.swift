//
//  Helper.swift
//  Intercessor
//
//  Created by Allen Lai on 8/20/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase

class Helper {
    
    static let helper = Helper()

    static let usersRef = FIRDatabase.database().reference().child("users")
    static let usernamesRef = FIRDatabase.database().reference().child("usernames")     // for finding friends purposes
    static let postsRef = FIRDatabase.database().reference().child("posts")
    static let groupsRef = FIRDatabase.database().reference().child("groups")
    static let directMessagesRef = FIRDatabase.database().reference().child("directMessages")
    static let groupMessagesRef = FIRDatabase.database().reference().child("groupMessages")

    static let hashTagsRef = FIRDatabase.database().reference().child("hashTags")
    
    static let featuredHashTagsRef = FIRDatabase.database().reference().child("featuredHashTags")
    static let featuredUsersRef = FIRDatabase.database().reference().child("featuredUsers")

    static let imageCache = NSCache<NSString, AnyObject>()
    
    
    func logInWithGoogle(_ authentication: GIDAuthentication) {
        
    }

    func switchToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "Tab Bar Controller") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }
    
    func switchToSignUpLogin() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let landingVC = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = landingVC
    }
    

    func downloadAndSaveProfileURL(_ profileURL: String) {
        if profileURL != "" {
            let url = URL(string: profileURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if let data = data {
                    if let downloadedImage = UIImage(data: data) {
                        Helper.imageCache.setObject(downloadedImage, forKey: profileURL as NSString)
                    }
                }
                
            }).resume()
        }
    }
    

    func getDirectMessageID(_ userID1: String, userID2: String) -> String {
        var directMessageID: String = ""
        
        let value = userID1.compare(userID2).rawValue

        if value < 0 {
            directMessageID = userID1 + userID2
        } else {
            directMessageID = userID2 + userID1
        }
        return directMessageID
    }
    
    func searchForDirectMessageInstanceLocally(_ userID1: String, userID2: String) -> DirectMessage? {
        let directMessageID = getDirectMessageID(userID1, userID2: userID2)
        for directMessage in UserRepo.currentUser.currMessages {
            if directMessage.messageID == directMessageID {
                return directMessage as? DirectMessage
            }
        }
        return nil
    }
    
    func sendDMToDirectmessageID(_ directMessageID: String, message: Message) {
        let newMessageRef = Helper.directMessagesRef.child(directMessageID).child("messages").childByAutoId()
        newMessageRef.setValue(message.toAnyObject())
    }
    
    func deleteUser(userID: String) {
        Helper.usersRef.child(userID).observeSingleEvent(of: .value, with: { (userSnapshot) in
            if userSnapshot.exists() {
                var user: User!
                user = User(snapshot: userSnapshot)
        
                for friend in user.friends {
                    Helper.usersRef.child(friend).child("friends").child(userID).setValue(nil)
                }
                for dm in user.directMessages {     // needs work
                    Helper.directMessagesRef.child(dm).setValue(nil)
                }
                Helper.usernamesRef.child(user.username).setValue(nil)
                for post in user.posts {
                    Helper.postsRef.child(post).setValue(nil)

                }
                Helper.usersRef.child(userID).setValue(nil)
            }
        })
    }
    
    
}



