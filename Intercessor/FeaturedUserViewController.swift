//
//  FeaturedUserViewController.swift
//  Odio
//
//  Created by Xavier Sharp on 12/28/15.
//  Copyright © 2015 XQ Creative, LLC. All rights reserved.
//

import UIKit

class FeaturedUserViewController: UIViewController {
    
    var parentVC: DiscoverVC!
    var userID: String!
    var user: User!
    var index: Int!

    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    
    
    @IBAction func userTapped(_ sender: AnyObject) {
//        parentVC.showProfile(user)
        Segues.showProfile(user: user, navigationController: self.navigationController!)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isHidden = true
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.update), name: NSNotification.Name(rawValue: kNotifFeaturedUsersLoaded), object: nil)
    }
    
    func update(notification: NSNotification) {
        user = parentVC.users[index]
        loadData()
    }
    
    func loadData() {
        
        let user = parentVC.users[index]
//        else {
//            userButton.isUserInteractionEnabled = false
//            return
//        }
        
        userButton.isUserInteractionEnabled = true
        
        if let username = user.username as String! {
            DispatchQueue.main.async(execute: {
                self.view.isHidden = false
                self.usernameLabel.text = "@\(username)"
            })
        }
        userProfile.loadImageUsingCacheWithUrlString(user.profilePicURL)

    }
    


    

}
