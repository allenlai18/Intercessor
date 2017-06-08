//
//  ActionSheet.swift
//  Intercessor
//
//  Created by Allen Lai on 11/24/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import Foundation
import MessageUI
import JDStatusBarNotification


open class ActionSheet: NSObject, MFMessageComposeViewControllerDelegate {
    
    var parentVC: UIViewController! = nil
    var post: Post!
    let notification = ALNotification()

    init(post: Post, vc: UIViewController) {
        self.post = post
        self.parentVC = vc
    }

    // initializing
    func openMoreOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { (action) -> Void in
            // Report
            self.reportPost(self.post)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            JDStatusBarNotification.show(withStatus: "Opening iMessage...",
                                         styleName: kJDStatusBarSuccess)
            JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: .gray)
            DispatchQueue.main.async {
                let message = MFMessageComposeViewController()
                message.body = self.post.turnPostToMessage()
                message.messageComposeDelegate = self
                self.parentVC.present(message, animated: true) {
                    JDStatusBarNotification.dismiss()
                }
                
            }
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) -> Void in
            Segues.showEditPost(post: self.post, viewController: self.parentVC)
            
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
            self.post.deletePostPermanent()
            //  reloadTableview
            if let homeVC = self.parentVC as? HomeVC {
                homeVC.tableView.reloadData()
            } else if let profileVC = self.parentVC as? ProfileVC {
                profileVC.tableView.reloadData()
            } else if let hashVC = self.parentVC as? HashTagVC {
                hashVC.tableView.reloadData()
            }
        
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(shareAction)
        
        if post.userID == UserRepo.currentUser.uid {
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
        } else {
            actionSheet.addAction(reportAction)
        }
        
        parentVC.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func reportPost(_ post: Post) {
        JDStatusBarNotification.show(withStatus: "Reporting Moment...", styleName: kJDStatusBarSuccess)
        JDStatusBarNotification.showActivityIndicator(true,
                                                      indicatorStyle: .gray)
        
        JDStatusBarNotification.show(withStatus: "Could not report moment",
                                     dismissAfter: 3.0,
                                     styleName: kJDStatusBarError)
        
    }

    
    
    // MFMessageComposeViewController
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.cancelled:
            self.messageCancelled()
            self.closeMessage()
            break
        case MessageComposeResult.failed:
            self.messageFailed()
            self.closeMessage()
            break
        case MessageComposeResult.sent:
            self.messageSent()
            self.closeMessage()
            break
        }
    }
    
    func openMessage(_ vc: MFMessageComposeViewController) {
        print("ShareMomentVC.swift - Open Message")
        parentVC.present(vc, animated: true) {
            JDStatusBarNotification.dismiss()
        }
    }
    func messageSent() {
        JDStatusBarNotification.show(withStatus: "Message sent!",
                                     dismissAfter: 2.0,
                                     styleName: kJDStatusBarSuccess)
        print("ShareMomentVC.swift - Message Sent")
    }
    func messageFailed() {
        JDStatusBarNotification.show(withStatus: "Message failed to send",
                                     dismissAfter: 2.0,
                                     styleName: kJDStatusBarError)
        print("ShareMomentVC.swift - Message Failed")
    }
    func messageCancelled() {
        print("ShareMomentVC.swift - Message Cancelled")
    }
    func closeMessage() {
        print("ShareMomentVC.swift - Close Message")
        parentVC.dismiss(animated: true, completion: nil)
    }

}



