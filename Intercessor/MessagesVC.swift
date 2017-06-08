//
//  MessagesVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/21/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class MessagesVC: UIViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    
    let activityIndicatorInstance: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTableView.tableFooterView = UIView()
        self.noMessagesLabel.isHidden = true
        

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kLoadCurrentUserMessages), object: nil, queue: OperationQueue.current, using: { (notification) in
            self.attemptReloadOfTable()
        })
        UserRepo.fetchObserveAllMessagesData()

        ActivityIndicator.startActivityIndicator(vc: self, indicator: activityIndicatorInstance)
        self.attemptReloadOfTable()
        checkIfEmpty()
        
        // refresh
        self.configureRefreshControl()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserRepo.currentUser.currMessages.count > 1 {
            UserRepo.currentUser.currMessages.sort{
                (($0.timeStamp)! as Date).compare(($1.timeStamp)! as Date) == .orderedDescending
            }
            messagesTableView.reloadData()
        }
    }
    
    
    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        
        UserRepo.currentUser.currMessages.sort{
            (($0.timeStamp)! as Date).compare(($1.timeStamp)! as Date) == .orderedDescending
        }

        DispatchQueue.main.async(execute: {
            ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
            self.messagesTableView.reloadData()
            if #available(iOS 10.0, *) {
                self.messagesTableView.refreshControl?.endRefreshing()
            } else {
                // Fallback on earlier versions
            }
        })
    }
    func checkIfEmpty() {
        Helper.usersRef.child(UserRepo.currentUser.uid).child("directMessages").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
                self.noMessagesLabel.isHidden = false
            }
        })
    }
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleReloadTable), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            messagesTableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "compose new message" {
            let composeViewController = segue.destination as! ComposeDMVC
            composeViewController.directMessagesVC = self
        }
    }
    
    func showGroupChat(groupID: String, groupMessage: GroupMessage) {
        let groupChatSB = UIStoryboard(name: "GroupMessage", bundle: nil)
        let groupChatViewController = groupChatSB.instantiateViewController(withIdentifier: "GroupChatVC") as! GroupChatVC
        groupChatViewController.groupMessage = groupMessage
        groupChatViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(groupChatViewController, animated: true)
    }

    

}

extension MessagesVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserRepo.currentUser.currMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "message cell", for: indexPath) as! MessagesTableViewCell
        cell.chatMessage = UserRepo.currentUser.currMessages[indexPath.row]
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell

    }
    
}
extension MessagesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = messagesTableView.cellForRow(at: indexPath) as! MessagesTableViewCell
        if let _ = cell.chatMessage as? DirectMessage {
            Segues.showDirectChatWithFriend(user: cell.friend, navigationController: self.navigationController!)
        } else {
            let groupMessage = cell.chatMessage as! GroupMessage
            showGroupChat(groupID: groupMessage.groupID, groupMessage: groupMessage)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


