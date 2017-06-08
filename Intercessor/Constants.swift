//
//  Constants.swift
//  Intercessor
//
//  Created by Allen Lai on 10/12/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//


// MARK: - Current User Data
public let kLoadCurrentUserMessages             = "loadCurrentUsersMessages"
public let kLoadCurrentUserNotifications        = "loadCurrentUsersNotifications"


// MARK: - loading Notifications
let kNotificationName                   = "alai.intercessor."
let kNotificationUtilityName            = kNotificationName + "utility."
public let kNotifFeaturedTagsLoaded     = kNotificationName + "featuredTagsLoaded"
public let kNotifFeaturedUsersLoaded    = kNotificationName + "featuredUsersLoaded"



// MARK: - Search Types
public let kSearchTypeUsers             = "users"
public let kSearchTypeHashtags          = "hashtags"



// MARK: - Placeholders
public let kPHSearchUsers               = "Search Users..."
public let kPHSearchHashtags            = "Search Hashtags..."



// MARK: - Cell Identifiers
public let kCellUser                    = "UserCell"
public let kCellHashtag                 = "HashtagCell"
public let kCellEmpty                   = "EmptyCell"
public let kCellComment                 = "CommentCell"


// MARK: - Segue Identifiers
public let SegueCommentsAll             = "viewAllComments"
public let SegueCommentsPopOver         = "commentsPopOver"


// MARK: - Status Bar Notifications
public let kJDStatusBarPending          = "Pending"
public let kJDStatusBarSuccess          = "Success"
public let kJDStatusBarError            = "Error"



class Constants {
    
    struct NotificationNames {
        static let reloadMyFeed                 = "reloadMyFeed"
        static let nothingNew                   = "nothingNew"
        static let reloadGroups                 = "reloadGroups"
        static let reloadNotifications          = "reloadNotifications"
        static let reloadMessages               = "reloadMessages"
        static let updateNotificationsBadge     = "updateNotificationsBadge"
        static let updateMessagesBadge          = "updateMessagesBadge"
    }
    
}







