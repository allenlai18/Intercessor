//
//  HashTagVC.swift
//  Intercessor
//
//  Created by Allen Lai on 10/16/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit


class HashTagVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emptyTableLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // DataSource
    var hashTagString: String!
    var hashTagPosts: [Post] = []
    
    let notification = ALNotification()
    let activityIndicatorInstance: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        emptyTableLabel.isHidden = true

        titleLabel.text = "#" + hashTagString
        ActivityIndicator.startActivityIndicator(vc: self, indicator: activityIndicatorInstance)
        
        Helper.hashTagsRef.child(hashTagString).observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? Bool ?? false) {
                let postID = snapshot.key
                Helper.postsRef.child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let newPost = Post(snapshot: snapshot)
                        self.hashTagPosts.append(newPost)
                        self.attemptReloadOfTable()
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
        self.emptyTableLabel.isHidden = true
        DispatchQueue.main.async(execute: {
            ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
            self.tableView.reloadData()
        })
    }
    func checkIfEmpty() {
        Helper.hashTagsRef.child(hashTagString).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                ActivityIndicator.stopActivityIndicator(indicator: self.activityIndicatorInstance)
                self.emptyTableLabel.isHidden = false
            }
        })
    }
    

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }



}

extension HashTagVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hashTagPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath) as! PostTableViewCell
        cell.cellPost = self.hashTagPosts[indexPath.row]
        cell.parentVC = self
        return cell
        
    }
    
}


extension HashTagVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    
}

