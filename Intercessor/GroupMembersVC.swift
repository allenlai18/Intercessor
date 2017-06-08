//
//  GroupMembersVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/29/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class GroupMembersVC: UIViewController {

    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var noMembersLabel: UILabel!
    
    var group: Group!
    var groupMembers: [User]! = []
    var potentialMembers: [User]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noMembersLabel.isHidden = true
        
        for gMemberID in group.users {
            Helper.usersRef.child(gMemberID).observeSingleEvent(of: .value, with: { (snapshot) in
                self.groupMembers.append(User(snapshot: snapshot))
                self.attemptReloadOfTable()

            })
        }
        self.potentialMembers = UserRepo.currentUser.allFriendsRepo.currFriends.filter({ user in !self.groupMembers.contains(where: { $0.username == user.username }) })


    }

    
    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.groupMembersTableView.reloadData()
        })
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }


}

extension GroupMembersVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return groupMembers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "group member cell", for: indexPath) as! GroupMembersTableViewCell
        cell.friend = groupMembers[indexPath.row]
        
        return cell
    }

}
extension GroupMembersVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Current Members"
        case 1:
            return "Add Friends to the Group"
        default:
            print("Error: in function titleForHeaderInSection", terminator: "")
            return "error"
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView   //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clear
        header.backgroundView!.backgroundColor = UIColor.clear
        
        header.textLabel!.textColor = UIColor(red: 140.0/255.0, green: 136.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "Avenir-Book", size: 12)
    }
}



