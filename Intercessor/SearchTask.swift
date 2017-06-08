//
//  Search.swift
//  Intercessor
//
//  Created by Allen Lai on 10/16/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation

open class Search {



    open class func hashTags(str: String, completion: @escaping (_ hashTags: [String]) -> Void) {
        if str.characters.count < 2 {
            completion([])
            return
        }
        
        let searchString = str.lowercased()
        Helper.hashTagsRef.observeSingleEvent(of: .value, with: { (snapshot) in

            let fetchedHashTags = snapshot.value as! [String: AnyObject]
            var hashTagsMatched: [String] = []
            for (hashTag, _) in fetchedHashTags {
                if hashTag.contains(searchString) {
                    hashTagsMatched.append(hashTag)
                }
            }
            completion(hashTagsMatched)
        })
    }
    
    open class func users(str: String, completion: @escaping (_ users: [Any]) -> Void) {
        if str.characters.count < 3 {
            completion([])
            return
        }
        let searchString = str.lowercased()
        
        Helper.usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let fetchedUsersDict = snapshot.value as! [String: AnyObject]
            var usersMatched: [User] = []
            for (uid, singlesUseDict) in fetchedUsersDict {
                let singleUseDictCasted = singlesUseDict as? [String: AnyObject] ?? [String: AnyObject]()
                let username = (singleUseDictCasted["username"] as! String).lowercased()

                if username.contains(searchString) {
                    usersMatched.append(User(snapshot: snapshot.childSnapshot(forPath: uid)))
                }
            }
            completion(usersMatched)
        })

    }
    
    


}



