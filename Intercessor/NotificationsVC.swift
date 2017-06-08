//
//  MessagesVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/21/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class NotificationsVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    let activityIndicatorInstance: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        emptyTableLabel.isHidden = true
        ActivityIndicator.startActivityIndicator(vc: self, indicator: activityIndicatorInstance)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kLoadCurrentUserNotifications), object: nil, queue: OperationQueue.current, using: { (notification) in
            self.attemptReloadOfTable()
        })

        UserRepo.fetchAllNotificationsData()
        checkIfEmpty()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FIRAnalytics.logEvent(withName: "Notification_Tab", parameters: nil)

    }

    
    // MARK: - Reload Table
    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        emptyTableLabel.isHidden = true
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
        })
    }
    func checkIfEmpty() {
        Helper.usersRef.child(UserRepo.currentUser.uid).child("notifications").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                // no notifications 
                ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
                self.emptyTableLabel.isHidden = false
            }
        })
    }

}

extension NotificationsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserRepo.currentUser.currNotifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notification cell", for: indexPath) as! NotificationTableViewCell
        cell.notification = UserRepo.currentUser.currNotifications[indexPath.row]
        cell.parentVC = self
        // make the seperator line go all the way across
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
}
extension NotificationsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellNotification = UserRepo.currentUser.currNotifications[indexPath.row]
//        if !cellNotification.seen {
//          Helper.usersRef.child(UserRepo.currentUser.uid).child("notifications").child(cellNotification.notificationID).child("seen").setValue(true)
//            cellNotification.seen = true
//            UserRepo.currentUser.numberOfNotificationsUnseen! -= 1
//        }
        if cellNotification.object == .post {
            Segues.showComments(poster: User(selfUser: UserRepo.currentUser), post: cellNotification.objectInstance as! Post, navigationController: self.navigationController!)
        } else if cellNotification.action == .accepted {
            Segues.showProfile(user: cellNotification.subject, navigationController: self.navigationController!)
        } else if cellNotification.object == .directMessage || cellNotification.object == .praiseReport
                            || cellNotification.object == .prayerRequest {
            Segues.showDirectChatWithFriend(user: cellNotification.subject, navigationController: self.navigationController!)
        }
        
    }
    
    
    // edit mode and deleting rows
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            //delete the notification on Firebase
            UserRepo.currentUser.currNotifications[indexPath.row].deleteNotificationOnFireBase()
            // delete locally
            UserRepo.currentUser.currNotifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
}






