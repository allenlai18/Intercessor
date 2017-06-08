//
//  Segues.swift
//  Intercessor
//
//  Created by Allen Lai on 11/18/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import Firebase


open class Segues {
    
    static func showComments(poster: User, post: Post, navigationController: UINavigationController) {
        let commentsSB = UIStoryboard(name: "CommentsVC", bundle: nil)
        let commentsViewController = commentsSB.instantiateViewController(withIdentifier: "comments") as! CommentsVC
        commentsViewController.poster = poster
        commentsViewController.post = post
        commentsViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(commentsViewController, animated: true)
    }
    static func showComments(post: Post, navigationController: UINavigationController) {
        let commentsSB = UIStoryboard(name: "CommentsVC", bundle: nil)
        let commentsViewController = commentsSB.instantiateViewController(withIdentifier: "comments") as! CommentsVC
        commentsViewController.post = post
        commentsViewController.hidesBottomBarWhenPushed = true
        AllFriendsRepo.sharedInstance.fetchUser(userID: post.userID) { (userFound) in
            commentsViewController.poster = userFound
            navigationController.pushViewController(commentsViewController, animated: true)
        }
    }
    static func goToHashTag(tagString: String, navigationController: UINavigationController) {
        let HashTagSB = UIStoryboard(name: "HashTag", bundle: nil)
        let hashTagViewController = HashTagSB.instantiateViewController(withIdentifier: "hashTag") as! HashTagVC
        hashTagViewController.hashTagString = tagString.lowercased()
        navigationController.pushViewController(hashTagViewController, animated: true)
    }

    static func showCurrentUsersListAllFriends(navigationController: UINavigationController) {
        let SB = UIStoryboard(name: "ListAllFriends", bundle: nil)
        let vc = SB.instantiateViewController(withIdentifier: "ListAllFriends") as! ListAllFriendsVC
        vc.isCurrentUser = true
        navigationController.pushViewController(vc, animated: true)
    }
    static func showListAllFriends(user: User, navigationController: UINavigationController) {
        let SB = UIStoryboard(name: "ListAllFriends", bundle: nil)
        let vc = SB.instantiateViewController(withIdentifier: "ListAllFriends") as! ListAllFriendsVC
        vc.user = user
        navigationController.pushViewController(vc, animated: true)
    }
    static func showProfile(user: User, navigationController: UINavigationController) {
        let viewProfileSB = UIStoryboard(name: "ViewProfileVC", bundle: nil)
        let viewProfileViewController = viewProfileSB.instantiateViewController(withIdentifier: "ViewProfile") as! ViewProfileVC
        viewProfileViewController.user = user
        navigationController.pushViewController(viewProfileViewController, animated: true)
    }
    static func goToPopoverComments(post: Post, selfParentVC: UIViewController, tabBarC: TabBarController) {
        let commentsPopoverSB = UIStoryboard(name: "CommentsPopover", bundle: nil)
        let vc = commentsPopoverSB.instantiateInitialViewController() as! CommentsPopOverViewController
        vc.post = post
        vc.parentVC = selfParentVC
        vc.modalTransitionStyle = .crossDissolve
        vc.hidesBottomBarWhenPushed = true
        selfParentVC.present(vc, animated: true, completion: {
            tabBarC.tabBar.isHidden = true
        })
    }
    static func showDirectChatWithFriend(user: User, navigationController: UINavigationController) {
        let directChatSB = UIStoryboard(name: "DirectMessage", bundle: nil)
        let directChatVC = directChatSB.instantiateViewController(withIdentifier: "DirectChatVC") as! DirectChatVC
        // check if there a DM with the current user.
        if let DM = Helper.helper.searchForDirectMessageInstanceLocally(UserRepo.currentUser.uid, userID2: user.uid) {
            directChatVC.directMessage = DM
            directChatVC.friend = user
            directChatVC.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(directChatVC, animated: true)
        } else {
            // CURRENTLY: You must have already have a DirectMessage with the user to chat with them
            
            directChatVC.veryFirstMessage = true
            directChatVC.friend = user

            print("failed finding the directMessage!!")
        }

    }
    static func showEditPost(post: Post, viewController: UIViewController) {
        FIRAnalytics.logEvent(withName: "Edit_Post", parameters: nil)
        let editPostSB = UIStoryboard(name: "EditPost", bundle: nil)
        let editVC = editPostSB.instantiateInitialViewController() as! EditPostVC
        editVC.post = post
        viewController.present(editVC, animated: true, completion: nil)
        
        
    }
    
    
}






