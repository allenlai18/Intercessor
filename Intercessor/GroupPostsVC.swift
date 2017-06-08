//
//  GroupPostsVC.swift
//  Intercessor
//
//  Created by Allen Lai on 8/28/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit

class GroupPostsVC: UIViewController {

    @IBOutlet weak var groupPostTableView: UITableView!
    @IBOutlet weak var noPostsLabel: UILabel!
    
    var group: Group!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI Stuff
        groupPostTableView.tableFooterView = UIView()
        setupNavBarWithGroup()
        if group.posts.count != 0 {
            noPostsLabel.isHidden = true
        }
        
        // set up an observer for group.posts
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "postsLoaded"), object: nil, queue: OperationQueue.current, using: { (notification) in
            self.attemptReloadOfTable()
        })
        
        
//        UserRepo.userRepoHelper.fetchGroupsPostsData(group)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // clean up observer
        
        NotificationCenter.default.removeObserver(self)
        Helper.postsRef.child(self.group.groupID).removeAllObservers()
    }


    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        if group.currPostsInGroup.isEmpty{
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        DispatchQueue.main.async(execute: {
            self.groupPostTableView.reloadData()
        })
    }

    func setupNavBarWithGroup() {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.loadImageUsingCacheWithUrlString(group.groupPicURL)
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "Avenir-Book", size: 18)
        nameLabel.text = group.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
    }
    
    func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show comment from group" {
            let cell = sender as! GroupPostsTableViewCell
            let commentsViewController = segue.destination as! CommentsVC
            commentsViewController.post = cell.cellPost
            commentsViewController.poster = cell.user
            commentsViewController.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "edit group members" {
            let groupMemberVC = segue.destination as! GroupMembersVC
            groupMemberVC.group = self.group
            groupMemberVC.hidesBottomBarWhenPushed = true
        }
    }
    
    
}

extension GroupPostsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.currPostsInGroup.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "group post cell", for: indexPath) as! GroupPostsTableViewCell
        cell.cellPost = group.currPostsInGroup[indexPath.row]
        return cell
    }
    
}


extension GroupPostsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}





