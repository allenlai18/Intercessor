//
//  ViewProfileVC.swift
//  Intercessor
//
//  Created by Allen Lai on 9/26/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit


class ViewProfileVC: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataImageView: UIImageView!

    var user: User!
    var friendsPosts: [Post] = [Post]()
    var userIsFriend: Bool = false
    let activityIndicatorInstance: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI Stuff
        emptyDataImageView.isHidden = true
        tableView.tableFooterView = UIView()
        
        ActivityIndicator.startActivityIndicator(vc: self, indicator: activityIndicatorInstance)
        if Relationship.findRelationshipWithUser(userID: user.uid) == .friends {
            userIsFriend = true
        }
        
        observeUserPosts()
        checkIfEmpty()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Helper.usersRef.child(user.uid).child("posts").removeAllObservers()
    }
    
    func observeUserPosts() {
        Helper.usersRef.child(user.uid).child("posts").observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? Bool ?? false) {
                let postID: String = snapshot.key
                Helper.postsRef.child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let postFetched = Post(snapshot: snapshot)
                        if (postFetched.privacy == .public) {
                            self.friendsPosts.insert(postFetched, at: 0)
                            self.attemptReloadOfTable()
                        } else if (postFetched.privacy == .friendsOnly && self.userIsFriend) {
                            self.friendsPosts.insert(postFetched, at: 0)
                            self.attemptReloadOfTable()
                        }
                    }
                })
            }
        })
    }


    var timer: Timer?
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable() {
        ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func checkIfEmpty() {
        Helper.usersRef.child(user.uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
                self.emptyDataImageView.isHidden = false
            }
        })
    }

    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    

 }

extension ViewProfileVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsPosts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderTableViewCell
            cell.parentVC = self
            cell.user = self.user
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath) as! PostTableViewCell
            cell.cellPost = friendsPosts[indexPath.row-1]
            cell.parentVC = self
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }

    }
    
}

extension ViewProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return tableView.bounds.height
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return tableView.bounds.height
        }
    }

}






