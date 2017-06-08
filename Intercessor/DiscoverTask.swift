//
//  DiscoverTask.swift
//  Intercessor
//
//  Created by Allen Lai on 10/11/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation

open class Discover {
    
    open class func getFeaturedHashTags(completion: @escaping (_ hashTags: [String]) -> Void) {
        
        Helper.featuredHashTagsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let featuredHashTags = snapshot.value as! [String]
            // call the function that was in the arguement
            completion(featuredHashTags)
            
        })
        
    }
    
    open class func getFeaturedUsers(completion: @escaping (_ usersFound: [Any]) -> Void) {
        
        Helper.featuredUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let featuredUserIDs = snapshot.value as! [String]
            var featuredUsers: [User] = []
            for userID in featuredUserIDs {
                AllFriendsRepo.sharedInstance.fetchUser(userID: userID, completion: { (user) in
                    featuredUsers.append(user)
                    if featuredUsers.count == 4 {
                        completion(featuredUsers)
                    }
                })
                
            }
            
        })
        
    }
    
    open class func saveFeaturedHashTags() {
        let featuredHashTags = ["love","blessed","harvestminded","family","prayer","newnew"]
        Helper.featuredHashTagsRef.setValue(featuredHashTags)
        
        
        
//        Helper.featuredHashTagsRef.child("love").setValue(true)
//        Helper.featuredUsersRef.child("blessed").setValue(true)
//        Helper.featuredUsersRef.child("harvestminded").setValue(true)
//        Helper.featuredUsersRef.child("family").setValue(true)
//        Helper.featuredUsersRef.child("prayer").setValue(true)
//        Helper.featuredUsersRef.child("newnew").setValue(true)

    }
    
    open class func saveFeaturedUsers() {
        let featuredUsers = ["optXrzpdqrNLE5PWrM6PIsplDan1",
                             "dKzN5Qlgu5NQaAl8sbwLqRBkjnf2",
                             "ftKJ4UUnjecEbNAvV6phVnlTNMB2",
                             "gdVANpyELRPPDyJYG8jW4z0BdGz2"
                            ]
        Helper.featuredUsersRef.setValue(featuredUsers)

        
//        Helper.featuredUsersRef.child("optXrzpdqrNLE5PWrM6PIsplDan1").setValue(true)
//        Helper.featuredUsersRef.child("dKzN5Qlgu5NQaAl8sbwLqRBkjnf2").setValue(true)
//        Helper.featuredUsersRef.child("ftKJ4UUnjecEbNAvV6phVnlTNMB2").setValue(true)
//        Helper.featuredUsersRef.child("hYbvkx0hTnYAHiyp9lzcN5W7lgj1").setValue(true)

        
        
    }
    
}
