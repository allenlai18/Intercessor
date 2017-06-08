//
//  FriendsVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/20/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit


class ListAllFriendsVC: UIViewController {

    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    // variables to set before
    var isCurrentUser: Bool = false       // either this is true or user is set
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFriendsTableView.tableFooterView = UIView()
        self.noFriendsLabel.isHidden = true
        setTitle()

    }

    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        // sort the currFriends
        UserRepo.currentUser.allFriendsRepo.currFriends.sort { (user1, user2) -> Bool in
            return user1.displayName < user2.displayName
        }
        DispatchQueue.main.async(execute: {
            self.allFriendsTableView.reloadData()
        })
    }
    
    
    @IBAction func leftBarButtonTapped(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    func setTitle() {
        if isCurrentUser {
            self.title = "My Friends"
        } else {
            self.title = user.displayName + "'s Friends"
        }
        
    }
}


extension ListAllFriendsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCurrentUser {
            return UserRepo.currentUser.allFriendsRepo.currFriends.count
        } else {
            return user.friends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend cell", for: indexPath) as! UserTableViewCell
        if isCurrentUser {
            cell.friend = UserRepo.currentUser.allFriendsRepo.currFriends[indexPath.row]
        } else {
            AllFriendsRepo.sharedInstance.fetchUser(userID: user.friends[indexPath.row]) { (userFound) in
                cell.friend = userFound
            }
        }
        return cell
    }
    
}


extension ListAllFriendsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isCurrentUser {
            Segues.showProfile(user: UserRepo.currentUser.allFriendsRepo.currFriends[indexPath.row], navigationController: self.navigationController!)
        } else {
            AllFriendsRepo.sharedInstance.fetchUser(userID: user.friends[indexPath.row]) { (userFound) in
                Segues.showProfile(user: userFound, navigationController: self.navigationController!)
            }
        }
    }
}





