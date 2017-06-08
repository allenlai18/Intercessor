//
//  ComposeDMVC.swift
//  Intercessor
//
//  Created by Allen Lai on 9/13/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class ComposeDMVC: UIViewController {

    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    var directMessagesVC: MessagesVC?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFriendsTableView.tableFooterView = UIView()
        if UserRepo.currentUser.allFriendsRepo.currFriends.count != 0 {
            self.noFriendsLabel.isHidden = true
        }

    }
    
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }


}


extension ComposeDMVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserRepo.currentUser.allFriendsRepo.currFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend cell", for: indexPath) as! UserTableViewCell
        cell.friend = UserRepo.currentUser.allFriendsRepo.currFriends[indexPath.row]
        cell.relationshipButton.isHidden = true
        return cell
    }
    
}


extension ComposeDMVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
            Segues.showDirectChatWithFriend(user: cell.friend, navigationController: directMessagesVC!.navigationController!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}







